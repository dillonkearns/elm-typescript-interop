module TypeScript.Parser exposing (extractAliases, extractMain, extractModuleName, extractPort, flagsType, moduleDeclaration, moduleStatementsFor, parse, parseSingle, programFlagType, statements, toProgram)

import Ast
import Ast.Expression exposing (..)
import ImportAlias exposing (ImportAlias)
import Result.Extra
import String.Interpolate
import TypeScript.Data.Aliases as Aliases
import TypeScript.Data.Port as Port exposing (Port(Port))
import TypeScript.Data.Program exposing (Main)


extractPort : List ImportAlias -> Aliases.LocalTypeDeclarations -> Ast.Expression.Statement -> Maybe Port
extractPort importAliases localTypeDeclarations statement =
    case statement of
        PortTypeDeclaration outboundPortName (TypeApplication outboundPortType (TypeConstructor [ "Cmd" ] [ TypeVariable _ ])) ->
            Port outboundPortName Port.Outbound outboundPortType importAliases localTypeDeclarations |> Just

        PortTypeDeclaration inboundPortName (TypeApplication (TypeApplication inboundPortType (TypeVariable _)) (TypeConstructor [ "Sub" ] [ TypeVariable _ ])) ->
            Port inboundPortName Port.Inbound inboundPortType importAliases localTypeDeclarations |> Just

        _ ->
            Nothing


type alias ParsedSourceFile =
    { path : String
    , statements : List Ast.Expression.Statement
    , importAliases : List ImportAlias
    }


toProgram : List ParsedSourceFile -> Result String TypeScript.Data.Program.Program
toProgram parsedSourceFiles =
    let
        statements =
            parsedSourceFiles |> List.map .statements

        ports =
            parsedSourceFiles
                |> List.map
                    (\parsedSourceFile -> List.filterMap (extractPort parsedSourceFile.importAliases (parsedSourceFile.statements |> Aliases.localTypeDeclarations)) parsedSourceFile.statements)
                |> List.concat

        aliases =
            statements
                |> List.map moduleStatementsFor
                |> List.map extractAliases
                |> List.concat
                |> Aliases.aliasesFromList
    in
    parsedSourceFiles
        |> flagsType
        |> (\mainFlagType -> TypeScript.Data.Program.ElmProgram mainFlagType aliases ports)
        |> Ok


type alias ModuleStatements =
    { moduleName : List String
    , statements : List Ast.Expression.Statement
    , importAliases : List ImportAlias
    }


moduleStatementsFor : List Statement -> ModuleStatements
moduleStatementsFor statements =
    let
        moduleName =
            extractModuleName statements
    in
    { moduleName = moduleName
    , statements = statements
    , importAliases =
        statements
            |> List.filterMap
                ImportAlias.fromExpression
    }


flagsType : List ParsedSourceFile -> List Main
flagsType parsedSourceFiles =
    parsedSourceFiles
        |> List.filterMap extractMain


extractMain : ParsedSourceFile -> Maybe Main
extractMain parsedSourceFile =
    let
        maybeFlagsType =
            parsedSourceFile.statements
                |> List.filterMap programFlagType
                |> List.head

        moduleName =
            extractModuleName parsedSourceFile.statements
    in
    maybeFlagsType
        |> Maybe.map
            (\flagsType ->
                { moduleName = moduleName
                , flagsType = flagsType
                , filePath = parsedSourceFile.path
                , importAliases = parsedSourceFile.statements |> List.filterMap ImportAlias.fromExpression
                , localTypeDeclarations = parsedSourceFile.statements |> Aliases.localTypeDeclarations
                }
            )


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


extractAliases : ModuleStatements -> List Aliases.Alias
extractAliases moduleStatements =
    moduleStatements.statements
        |> List.filterMap
            (aliasOrNothing (moduleStatements.statements |> Aliases.localTypeDeclarations) moduleStatements.moduleName moduleStatements.importAliases)


type alias UnqualifiedModuleName =
    List String


aliasOrNothing : Aliases.LocalTypeDeclarations -> UnqualifiedModuleName -> List ImportAlias -> Ast.Expression.Statement -> Maybe Aliases.Alias
aliasOrNothing localTypeDeclarations moduleName importAliases statement =
    case statement of
        TypeAliasDeclaration (TypeConstructor aliasName []) aliasType ->
            Aliases.alias localTypeDeclarations ((moduleName |> Debug.log "moduleName") ++ aliasName) importAliases aliasType
                |> Just
                |> Debug.log "Result"

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


statements : List SourceFile -> Result String (List ParsedSourceFile)
statements sourceFiles =
    sourceFiles
        |> List.map
            (\sourceFile ->
                sourceFile
                    |> statementsForSingle
                    |> Result.map
                        (\statements ->
                            { path = sourceFile.path
                            , statements = statements
                            , importAliases = statements |> List.filterMap ImportAlias.fromExpression
                            }
                        )
            )
        |> Result.Extra.combine


statementsForSingle : SourceFile -> Result String (List Statement)
statementsForSingle sourceFile =
    sourceFile
        |> .contents
        |> Ast.parse
        |> Result.map (\( _, _, statements ) -> statements)
        |> Result.mapError
            (\( state, inputStream, errorMessages ) ->
                [ sourceFile.path
                , inputStream.position |> toString
                , errorMessages |> String.join "\n"
                ]
                    |> String.Interpolate.interpolate
                        "Could not parse file `{0}` at position {1}. Errors:\n{2}"
            )


type alias SourceFile =
    { path : String, contents : String }


parse : List SourceFile -> Result String TypeScript.Data.Program.Program
parse sourceFiles =
    case sourceFiles |> statements of
        Ok fileAsts ->
            toProgram fileAsts

        Err err ->
            Err err
