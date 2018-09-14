module TypeScript.Data.Aliases exposing (Alias, Aliases, alias, aliasesFromList, lookupAlias)

import Ast.Expression
import Dict exposing (Dict)
import ImportAlias exposing (ImportAlias)
import String.Interpolate


type Alias
    = Alias UnqualifiedTypeReference Ast.Expression.Type


lookupImportAlias : List String -> List ImportAlias -> Maybe ImportAlias
lookupImportAlias moduleName importAliases =
    importAliases
        |> List.filter (\importAlias -> True)
        |> List.head


type UnqualifiedTypeReference
    = UnqualifiedTypeReference (List String)


unqualifiedTypeReference : List String -> List ImportAlias -> UnqualifiedTypeReference
unqualifiedTypeReference rawTypeReferenceName importAliases =
    (case rawTypeReferenceName |> List.reverse of
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


alias : List String -> List ImportAlias -> Ast.Expression.Type -> Alias
alias name importAliases astType =
    Alias (unqualifiedTypeReference name importAliases) astType


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


lookupAlias : Aliases -> List String -> Result String Ast.Expression.Type
lookupAlias (Aliases aliases) aliasName =
    case
        aliases
            |> lookupAliasEntry aliasName
    of
        Just foundTsTypeName ->
            Ok foundTsTypeName

        Nothing ->
            [ String.join "." aliasName
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
