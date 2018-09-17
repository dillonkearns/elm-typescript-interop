module TypeScript.Parser exposing (extractAliases, extractContext, extractContexts, extractMain, extractModuleName, extractPort, extractPorts, flagsType, moduleDeclaration, moduleStatementsFor, parse, parseSingle, programFlagType)

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


extractPort : Context -> Ast.Expression.Statement -> Maybe Port
extractPort context statement =
    case statement of
        PortTypeDeclaration outboundPortName (TypeApplication outboundPortType (TypeConstructor [ "Cmd" ] [ TypeVariable _ ])) ->
            Port context outboundPortName Port.Outbound outboundPortType |> Just

        PortTypeDeclaration inboundPortName (TypeApplication (TypeApplication inboundPortType (TypeVariable _)) (TypeConstructor [ "Sub" ] [ TypeVariable _ ])) ->
            Port context inboundPortName Port.Inbound inboundPortType |> Just

        _ ->
            Nothing


extractPorts : List Context -> List Port
extractPorts contexts =
    contexts
        |> List.map
            (\context ->
                List.filterMap (extractPort context) context.statements
            )
        |> List.concat


toProgram : List Context -> Result String TypeScript.Data.Program.Program
toProgram contexts =
    let
        ports =
            extractPorts contexts

        aliases =
            contexts
                |> List.map extractAliases
                |> List.concat
                |> Aliases.aliasesFromList
    in
    contexts
        |> flagsType
        |> Result.map (\mainFlagType -> TypeScript.Data.Program.ElmProgram mainFlagType aliases ports)


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


flagsType : List Context -> Result String (List Main)
flagsType parsedSourceFiles =
    parsedSourceFiles
        |> List.map extractMain
        |> Result.Extra.combine
        |> Result.map (List.filterMap identity)


extractMain : Context -> Result String (Maybe Main)
extractMain context =
    let
        maybeFlagsType =
            context.statements
                |> List.filterMap programFlagType
                |> List.head

        moduleName =
            extractModuleName context.statements
    in
    maybeFlagsType
        |> Maybe.map
            (\flagsType ->
                { context = context
                , flagsType = flagsType
                }
            )
        |> Ok


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
aliasOrNothing ({ localTypeDeclarations, moduleName, importAliases } as context) statement =
    case statement of
        TypeAliasDeclaration (TypeConstructor aliasName []) aliasType ->
            Aliases.alias context (moduleName ++ aliasName) aliasType
                |> Just

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


extractContexts : List SourceFile -> Result String (List Context)
extractContexts sourceFiles =
    sourceFiles
        |> List.map extractContext
        |> Result.Extra.combine


extractContext : SourceFile -> Result String Context
extractContext sourceFile =
    sourceFile
        |> statementsForSingle
        |> Result.map
            (\statements ->
                { filePath = sourceFile.path
                , statements = statements
                , importAliases = statements |> List.filterMap ImportAlias.fromExpression
                , moduleName = extractModuleName statements
                , localTypeDeclarations = statements |> LocalTypeDeclarations.fromStatements
                }
            )


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
    case extractContexts sourceFiles of
        Ok fileAsts ->
            toProgram fileAsts

        Err err ->
            Err err
