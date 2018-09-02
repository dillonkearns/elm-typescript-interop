module TypeScript.Data.Aliases exposing (Aliases, AliasesNew, aliases, lookupAlias)

import Ast.Expression
import Dict exposing (Dict)
import String.Interpolate


aliases : AliasesInner -> Aliases
aliases aliasesInner =
    Aliases aliasesInner


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


type alias AliasesNew =
    List ( List String, Ast.Expression.Type )
