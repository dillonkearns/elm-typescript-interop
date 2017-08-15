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


toProgram : List (List Ast.Statement.Statement) -> TypeScript.Data.Program.Program
toProgram statements =
    let
        ports =
            List.filterMap extractPort flatStatements

        flagsType =
            statements
                |> List.filterMap extractMain
                |> List.head

        aliases =
            extractAliases flatStatements

        flatStatements =
            List.concat statements
    in
    TypeScript.Data.Program.ElmProgram flagsType aliases ports


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
    Maybe.map (\flagsType -> { moduleName = moduleName, flagsType = flagsType }) maybeFlagsType


extractModuleName : List Ast.Statement.Statement -> List String
extractModuleName statementStatementAstList =
    []


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


programFlagType : Ast.Statement.Statement -> Maybe Ast.Statement.Type
programFlagType statement =
    case statement of
        FunctionTypeDeclaration "main" (TypeConstructor [ "Program" ] [ flagsType, TypeConstructor [ modelType ] [], TypeConstructor [ msgType ] [] ]) ->
            case flagsType of
                TypeConstructor [ "Never" ] [] ->
                    Nothing

                _ ->
                    Just flagsType

        _ ->
            Nothing


parseSingle : String -> Result String TypeScript.Data.Program.Program
parseSingle ipcFileAsString =
    parse [ ipcFileAsString ]


parse : List String -> Result String TypeScript.Data.Program.Program
parse ipcFilesAsStrings =
    let
        statements =
            List.map Ast.parse ipcFilesAsStrings
                |> Result.Extra.combine
    in
    case statements of
        Ok fileAsts ->
            fileAsts
                |> List.map (\( _, _, statements ) -> statements)
                |> toProgram
                |> Ok

        err ->
            err |> toString |> Err
