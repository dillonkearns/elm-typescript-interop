module TypeScript.Parser exposing (extractAliasesNew, extractMain, extractModuleName, extractPort, flagsType, moduleDeclaration, moduleStatementsFor, parse, parseSingle, programFlagType, statements, toProgram)

import Ast
import Ast.Expression exposing (..)
import Dict
import Result.Extra
import TypeScript.Data.Aliases exposing (Aliases, AliasesNew)
import TypeScript.Data.Port as Port exposing (Port(Port))
import TypeScript.Data.Program exposing (Main)


extractPort : Ast.Expression.Statement -> Maybe Port
extractPort statement =
    case statement of
        PortTypeDeclaration outboundPortName (TypeApplication outboundPortType (TypeConstructor [ "Cmd" ] [ TypeVariable _ ])) ->
            Port outboundPortName Port.Outbound outboundPortType |> Just

        PortTypeDeclaration inboundPortName (TypeApplication (TypeApplication inboundPortType (TypeVariable _)) (TypeConstructor [ "Sub" ] [ TypeVariable _ ])) ->
            Port inboundPortName Port.Inbound inboundPortType |> Just

        _ ->
            Nothing


toProgram : List (List Ast.Expression.Statement) -> Result String TypeScript.Data.Program.Program
toProgram statements =
    let
        ports =
            List.filterMap extractPort flatStatements

        aliasesNew =
            statements
                |> List.map moduleStatementsFor
                |> List.map extractAliasesNew
                |> List.concat
                |> Dict.fromList
                |> TypeScript.Data.Aliases.aliases

        flatStatements =
            List.concat statements
    in
    Result.map (\mainFlagType -> TypeScript.Data.Program.ElmProgram mainFlagType aliasesNew ports)
        (flagsType statements)


type alias ModuleStatements =
    { moduleName : List String
    , statements : List Ast.Expression.Statement
    }


moduleStatementsFor : List Statement -> ModuleStatements
moduleStatementsFor statements =
    let
        moduleName =
            extractModuleName statements
    in
    { moduleName = moduleName
    , statements = statements
    }


flagsType : List (List Ast.Expression.Statement) -> Result String Main
flagsType statements =
    let
        mainCandidates =
            statements
                |> List.filterMap extractMain
    in
    case mainCandidates of
        -- TODO use a list, pass in the filenames associated with each module and lookup based on that.
        [] ->
            Err "No main function with type annotation found."

        [ singleMain ] ->
            Ok singleMain

        multipleMains ->
            Err ("Multiple mains with type annotations found: " ++ toString multipleMains)


extractMain : List Ast.Expression.Statement -> Maybe Main
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


extractModuleName : List Ast.Expression.Statement -> List String
extractModuleName statements =
    statements
        |> List.filterMap moduleDeclaration
        |> List.head
        |> Maybe.withDefault []


moduleDeclaration : Ast.Expression.Statement -> Maybe (List String)
moduleDeclaration statement =
    case statement of
        ModuleDeclaration moduleName _ ->
            Just moduleName

        PortModuleDeclaration moduleName _ ->
            Just moduleName

        EffectsModuleDeclaration moduleName _ _ ->
            Just moduleName

        _ ->
            Nothing


extractAliasesNew : ModuleStatements -> AliasesNew
extractAliasesNew moduleStatements =
    moduleStatements.statements
        |> List.filterMap (aliasOrNothingNew moduleStatements.moduleName)


type alias UnqualifiedModuleName =
    List String


aliasOrNothingNew : UnqualifiedModuleName -> Ast.Expression.Statement -> Maybe ( List String, Ast.Expression.Type )
aliasOrNothingNew moduleName statement =
    case statement of
        TypeAliasDeclaration (TypeConstructor aliasName []) aliasType ->
            Just ( moduleName ++ aliasName, aliasType )

        _ ->
            Nothing


programFlagType : Ast.Expression.Statement -> Maybe (Maybe Ast.Expression.Type)
programFlagType statement =
    case statement of
        FunctionTypeDeclaration "main" mainSubtree ->
            case mainSubtree of
                TypeConstructor [ "Program" ] (flagsType :: _) ->
                    case flagsType of
                        TypeConstructor [ "Never" ] _ ->
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


parseSingle : SourceFile -> Result String TypeScript.Data.Program.Program
parseSingle ipcFileAsString =
    parse [ ipcFileAsString ]


statements : List SourceFile -> Result String (List (List Statement))
statements sourceFiles =
    sourceFiles
        |> List.map .contents
        |> List.map Ast.parse
        |> Result.Extra.combine
        |> Result.map (List.map (\( _, _, statements ) -> statements))
        |> Result.mapError toString


type alias SourceFile =
    { path : String, contents : String }


parse : List SourceFile -> Result String TypeScript.Data.Program.Program
parse sourceFiles =
    case sourceFiles |> statements of
        Ok fileAsts ->
            toProgram fileAsts

        Err err ->
            Err err
