module TypeScript.Data.Aliases exposing (Alias, Aliases, LocalTypeDeclarations, UnqualifiedTypeReference, alias, aliasesFromList, localTypeDeclarations, lookupAlias, unqualifiedTypeReference)

import Ast.Expression
import Dict exposing (Dict)
import ImportAlias exposing (ImportAlias)
import String.Interpolate


type Alias
    = Alias UnqualifiedTypeReference Ast.Expression.Type


lookupImportAlias : List String -> List ImportAlias -> Maybe ImportAlias
lookupImportAlias moduleName importAliases =
    case moduleName of
        [ possibleModuleAlias ] ->
            importAliases
                |> List.filter (\importAlias -> possibleModuleAlias == importAlias.aliasName)
                |> List.head

        _ ->
            Nothing


type UnqualifiedTypeReference
    = UnqualifiedTypeReference (List String)


type LocalTypeDeclarations
    = LocalTypeDeclarations (List String)


localTypeDeclarations : List Ast.Expression.Statement -> LocalTypeDeclarations
localTypeDeclarations statements =
    List.filterMap typeDeclaration statements
        |> LocalTypeDeclarations


typeDeclaration : Ast.Expression.Statement -> Maybe String
typeDeclaration statement =
    case statement of
        Ast.Expression.TypeDeclaration (Ast.Expression.TypeConstructor [ typeName ] _) _ ->
            Just typeName

        Ast.Expression.TypeAliasDeclaration (Ast.Expression.TypeConstructor [ typeName ] _) _ ->
            Just typeName

        _ ->
            Nothing


unqualifiedTypeReference : List String -> LocalTypeDeclarations -> List String -> List ImportAlias -> UnqualifiedTypeReference
unqualifiedTypeReference callingModuleName (LocalTypeDeclarations localTypeDeclarations) rawTypeReferenceName importAliases =
    (case rawTypeReferenceName |> List.reverse of
        [ typeName ] ->
            let
                localTypeOverride =
                    localTypeDeclarations
                        |> List.member typeName
            in
            if localTypeOverride then
                callingModuleName ++ [ typeName ]

            else
                case lookupImportAlias [ typeName ] importAliases of
                    Just importAlias ->
                        importAlias.unqualifiedModuleName ++ [ typeName ]

                    Nothing ->
                        [ typeName ]

        typeName :: backwardsModuleName ->
            let
                moduleName =
                    backwardsModuleName |> List.reverse
            in
            case lookupImportAlias moduleName importAliases of
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


alias : List String -> LocalTypeDeclarations -> List String -> List ImportAlias -> Ast.Expression.Type -> Alias
alias callingModuleName localTypeDeclarations name importAliases astType =
    let
        maybeUnqualifiedNameOverride =
            case astType of
                Ast.Expression.TypeConstructor typeName _ ->
                    if unqualifiedTypeReference callingModuleName localTypeDeclarations typeName importAliases == jsonDecodeValue then
                        Ast.Expression.TypeConstructor [ "Json", "Decode", "Value" ] []
                            |> Just

                    else if unqualifiedTypeReference callingModuleName localTypeDeclarations typeName importAliases == jsonEncodeValue then
                        Ast.Expression.TypeConstructor [ "Json", "Encode", "Value" ] []
                            |> Just

                    else
                        Nothing

                _ ->
                    Nothing
    in
    Alias (unqualifiedTypeReference callingModuleName localTypeDeclarations name importAliases) (maybeUnqualifiedNameOverride |> Maybe.withDefault astType)


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
    aliases
        |> Dict.get aliasName
