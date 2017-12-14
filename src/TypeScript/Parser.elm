module TypeScript.Parser exposing (..)

import Ast
import Ast.Statement exposing (..)
import Dict
import Result.Extra
import TypeScript.Data.Aliases exposing (Aliases)
import TypeScript.Data.Port as Port exposing (Port(Port))
import TypeScript.Data.Program exposing (Main)


extractPort : Ast.Statement.Statement -> Maybe Port
extractPort statement =
    case statement of
        PortTypeDeclaration outboundPortName (TypeApplication outboundPortType (TypeConstructor [ "Cmd" ] [ TypeVariable _ ])) ->
            Port outboundPortName Port.Outbound outboundPortType |> Just

        PortTypeDeclaration inboundPortName (TypeApplication (TypeApplication inboundPortType (TypeVariable _)) (TypeConstructor [ "Sub" ] [ TypeVariable _ ])) ->
            Port inboundPortName Port.Inbound inboundPortType |> Just

        _ ->
            Nothing


toProgram : List (List Ast.Statement.Statement) -> Result String TypeScript.Data.Program.Program
toProgram statements =
    let
        ports =
            List.filterMap extractPort flatStatements

        aliases =
            extractAliases flatStatements

        flatStatements =
            List.concat statements
    in
    Result.map (\mainFlagType -> TypeScript.Data.Program.ElmProgram mainFlagType aliases ports)
        (flagsType statements)


flagsType : List (List Ast.Statement.Statement) -> Result String Main
flagsType statements =
    let
        mainCandidates =
            statements
                |> List.filterMap extractMain
    in
    case mainCandidates of
        [] ->
            Err "No main function with type annotation found."

        [ singleMain ] ->
            Ok singleMain

        multipleMains ->
            Err ("Multiple mains with type annotations found: " ++ toString multipleMains)


extractMain : List Ast.Statement.Statement -> Maybe Main
extractMain statements =
    let
        maybeFlagsType =
            statements
                |> List.filterMap programFlagType
                |> List.head

        moduleName =
            extractModuleName statements
    in
    maybeFlagsType |> Maybe.map (\flagsType -> { moduleName = moduleName, flagsType = flagsType })


extractModuleName : List Ast.Statement.Statement -> List String
extractModuleName statements =
    statements
        |> List.filterMap moduleDeclaration
        |> List.head
        |> Maybe.withDefault []


moduleDeclaration : Ast.Statement.Statement -> Maybe (List String)
moduleDeclaration statement =
    case statement of
        ModuleDeclaration moduleName _ ->
            Just moduleName

        PortModuleDeclaration moduleName _ ->
            Just moduleName

        EffectModuleDeclaration moduleName _ _ ->
            Just moduleName

        _ ->
            Nothing


extractAliases : List Ast.Statement.Statement -> Aliases
extractAliases statements =
    statements
        |> List.filterMap aliasOrNothing
        |> Dict.fromList


aliasOrNothing : Ast.Statement.Statement -> Maybe ( List String, Ast.Statement.Type )
aliasOrNothing statement =
    case statement of
        TypeAliasDeclaration (TypeConstructor aliasName []) aliasType ->
            Just ( aliasName, aliasType )

        _ ->
            Nothing


programFlagType : Ast.Statement.Statement -> Maybe (Maybe Ast.Statement.Type)
programFlagType statement =
    case statement of
        FunctionTypeDeclaration "main" mainSubtree ->
            case mainSubtree of
                TypeConstructor [ "Program" ] (flagsType :: _) ->
                    case flagsType of
                        TypeConstructor [ "Never" ] [] ->
                            Just Nothing

                        _ ->
                            Just (Just flagsType)

                TypeConstructor [ "Html" ] _ ->
                    Just Nothing

                TypeConstructor [ "Html.Html" ] _ ->
                    Just Nothing

                _ ->
                    Nothing

        _ ->
            Nothing


parseSingle : String -> Result String TypeScript.Data.Program.Program
parseSingle ipcFileAsString =
    parse [ ipcFileAsString ]


statements : List String -> Result String (List (List Statement))
statements ipcFilesAsStrings =
    List.map Ast.parse ipcFilesAsStrings
        |> Result.Extra.combine
        |> Result.map (List.map (\( _, _, statements ) -> statements))
        |> Result.mapError toString


parse : List String -> Result String TypeScript.Data.Program.Program
parse ipcFilesAsStrings =
    case statements ipcFilesAsStrings of
        Ok fileAsts ->
            fileAsts
                |> toProgram

        Err err ->
            Err err
