module TypeScript.Data.Aliases exposing (Alias, Aliases, UnqualifiedTypeReference, alias, aliasesFromList, elmPrimitiveToTs, lookupAlias, unqualifiedTypeReference)

import Ast.Expression
import Dict exposing (Dict)
import ImportAlias exposing (ImportAlias)
import Parser.Context exposing (Context)
import Parser.LocalTypeDeclarations as LocalTypeDeclarations exposing (LocalTypeDeclarations)
import String.Interpolate


type Alias
    = Alias UnqualifiedTypeReference Ast.Expression.Type


lookupImportAlias : List String -> Context -> Maybe ImportAlias
lookupImportAlias moduleName context =
    case moduleName of
        [ possibleModuleAlias ] ->
            context.importAliases
                |> List.filter (\importAlias -> possibleModuleAlias == importAlias.aliasName)
                |> List.head

        _ ->
            Nothing


type UnqualifiedTypeReference
    = UnqualifiedTypeReference (List String)


elmPrimitiveToTs : UnqualifiedTypeReference -> Maybe String
elmPrimitiveToTs (UnqualifiedTypeReference elmPrimitive) =
    case elmPrimitive of
        [ "String" ] ->
            Just "string"

        [ "Int" ] ->
            Just "number"

        [ "Float" ] ->
            Just "number"

        [ "Bool" ] ->
            Just "boolean"

        [ "Json", "Decode", "Value" ] ->
            Just "unknown"

        [ "Json", "Encode", "Value" ] ->
            Just "unknown"

        _ ->
            Nothing


unqualifiedTypeReference : Context -> List String -> UnqualifiedTypeReference
unqualifiedTypeReference context rawTypeReferenceName =
    (case rawTypeReferenceName |> List.reverse of
        [ typeName ] ->
            let
                localTypeOverride =
                    LocalTypeDeclarations.includes typeName context.localTypeDeclarations
            in
            if localTypeOverride then
                context.moduleName ++ [ typeName ]

            else
                case lookupImportAlias [ typeName ] context of
                    Just importAlias ->
                        importAlias.unqualifiedModuleName ++ [ typeName ]

                    Nothing ->
                        [ typeName ]

        typeName :: backwardsModuleName ->
            let
                moduleName =
                    backwardsModuleName |> List.reverse
            in
            case lookupImportAlias moduleName context of
                Just importAlias ->
                    importAlias.unqualifiedModuleName ++ [ typeName ]

                Nothing ->
                    moduleName ++ [ typeName ]

        [] ->
            []
    )
        |> UnqualifiedTypeReference


jsonDecodeValue : UnqualifiedTypeReference
jsonDecodeValue =
    UnqualifiedTypeReference [ "Json", "Decode", "Value" ]


jsonEncodeValue : UnqualifiedTypeReference
jsonEncodeValue =
    UnqualifiedTypeReference [ "Json", "Encode", "Value" ]


alias : Context -> List String -> Ast.Expression.Type -> Alias
alias context name astType =
    let
        maybeUnqualifiedNameOverride =
            case astType of
                Ast.Expression.TypeConstructor typeName _ ->
                    if unqualifiedTypeReference context typeName == jsonDecodeValue then
                        Ast.Expression.TypeConstructor [ "Json", "Decode", "Value" ] []
                            |> Just

                    else if unqualifiedTypeReference context typeName == jsonEncodeValue then
                        Ast.Expression.TypeConstructor [ "Json", "Encode", "Value" ] []
                            |> Just

                    else
                        Nothing

                _ ->
                    Nothing
    in
    Alias (unqualifiedTypeReference context name) (maybeUnqualifiedNameOverride |> Maybe.withDefault astType)


aliasesFromList : List Alias -> Aliases
aliasesFromList aliases =
    aliases
        |> List.map
            (\(Alias (UnqualifiedTypeReference unqualifiedTypeReference) astType) ->
                ( unqualifiedTypeReference, astType )
            )
        |> Dict.fromList
        |> Aliases


type Aliases
    = Aliases AliasesInner


type alias AliasesInner =
    Dict (List String) Ast.Expression.Type


lookupAlias : Aliases -> UnqualifiedTypeReference -> Result String Ast.Expression.Type
lookupAlias (Aliases aliases) (UnqualifiedTypeReference unqualifiedAliasName) =
    case
        aliases
            |> lookupAliasEntry unqualifiedAliasName
    of
        Just foundTsTypeName ->
            Ok foundTsTypeName

        Nothing ->
            [ String.join "." unqualifiedAliasName
            , knownAliases aliases
                |> String.join ", "
            ]
                |> String.Interpolate.interpolate "Alias `{0}` not found. Known aliases:\n{1}"
                |> Err


knownAliases : AliasesInner -> List String
knownAliases aliases =
    aliases
        |> Dict.keys
        -- |> List.map (\( qualifiedAliasName, aliasType ) -> qualifiedAliasName)
        |> List.map (String.join ".")


lookupAliasEntry : List String -> AliasesInner -> Maybe Ast.Expression.Type
lookupAliasEntry aliasName aliases =
    case
        aliases
            |> Dict.get aliasName
    of
        Nothing ->
            case aliasName |> List.reverse |> List.head of
                Just unqualifiedName ->
                    aliases
                        |> Dict.toList
                        |> List.filterMap
                            (\( moduleName, expression ) ->
                                if Just unqualifiedName == (moduleName |> List.reverse |> List.head) then
                                    Just expression

                                else
                                    Nothing
                            )
                        |> List.head

                Nothing ->
                    Nothing

        Just something ->
            Just something
