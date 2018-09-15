module TypeScript.Parser exposing (extractAliases, extractMain, extractModuleName, extractPort, flagsType, moduleDeclaration, moduleStatementsFor, parse, parseSingle, programFlagType, statements, toProgram)

import Ast
import Ast.Expression exposing (..)
import ImportAlias exposing (ImportAlias)
import Parser.Context exposing (Context)
import Parser.LocalTypeDeclarations as LocalTypeDeclarations exposing (LocalTypeDeclarations)
import Result.Extra
import String.Interpolate
import TypeScript.Data.Aliases as Aliases
import TypeScript.Data.Port as Port exposing (Port(Port))
import TypeScript.Data.Program exposing (Main)


extractPort : Context -> List String -> List ImportAlias -> LocalTypeDeclarations -> Ast.Expression.Statement -> Maybe Port
extractPort context moduleName importAliases localTypeDeclarations statement =
    case statement of
        PortTypeDeclaration outboundPortName (TypeApplication outboundPortType (TypeConstructor [ "Cmd" ] [ TypeVariable _ ])) ->
            Port context outboundPortName Port.Outbound outboundPortType importAliases localTypeDeclarations moduleName |> Just

        PortTypeDeclaration inboundPortName (TypeApplication (TypeApplication inboundPortType (TypeVariable _)) (TypeConstructor [ "Sub" ] [ TypeVariable _ ])) ->
            Port context inboundPortName Port.Inbound inboundPortType importAliases localTypeDeclarations moduleName |> Just

        _ ->
            Nothing


type alias ParsedSourceFile =
    { path : String
    , statements : List Ast.Expression.Statement
    , importAliases : List ImportAlias
    , moduleName : List String
    }


toProgram : List ParsedSourceFile -> Result String TypeScript.Data.Program.Program
toProgram parsedSourceFiles =
    let
        ports =
            contexts
                |> List.map
                    (\context ->
                        List.filterMap
                            (extractPort context
                                context.moduleName
                                context.importAliases
                                (context.statements
                                    |> LocalTypeDeclarations.fromStatements
                                )
                            )
                            context.statements
                    )
                |> List.concat

        contexts =
            parsedSourceFiles
                |> List.map parsedSourceFileToContext

        aliases =
            contexts
                |> List.map extractAliases
                |> List.concat
                |> Aliases.aliasesFromList
    in
    parsedSourceFiles
        |> flagsType
        |> (\mainFlagType -> TypeScript.Data.Program.ElmProgram mainFlagType aliases ports)
        |> Ok


parsedSourceFileToContext : ParsedSourceFile -> Context
parsedSourceFileToContext parsedSourceFile =
    { filePath = parsedSourceFile.path
    , statements = parsedSourceFile.statements
    , importAliases = parsedSourceFile.importAliases
    , localTypeDeclarations = parsedSourceFile.statements |> LocalTypeDeclarations.fromStatements
    , moduleName = parsedSourceFile.moduleName
    }


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
                { context =
                    { moduleName = moduleName
                    , filePath = parsedSourceFile.path
                    , importAliases = parsedSourceFile.statements |> List.filterMap ImportAlias.fromExpression
                    , localTypeDeclarations = parsedSourceFile.statements |> LocalTypeDeclarations.fromStatements
                    , statements = parsedSourceFile.statements
                    }
                , flagsType = flagsType
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


extractAliases : Context -> List Aliases.Alias
extractAliases context =
    context.statements
        |> List.filterMap (aliasOrNothing context)


type alias UnqualifiedModuleName =
    List String


aliasOrNothing : Parser.Context.Context -> Ast.Expression.Statement -> Maybe Aliases.Alias
aliasOrNothing { localTypeDeclarations, moduleName, importAliases } statement =
    case statement of
        TypeAliasDeclaration (TypeConstructor aliasName []) aliasType ->
            Aliases.alias moduleName localTypeDeclarations ((moduleName |> Debug.log "moduleName") ++ aliasName) importAliases aliasType
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
                            , moduleName = extractModuleName statements
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
