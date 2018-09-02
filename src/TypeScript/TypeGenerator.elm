module TypeScript.TypeGenerator exposing (toTsType)

import Ast.Expression exposing (Type(TypeConstructor, TypeRecord, TypeTuple))
import Dict
import Result.Extra
import String.Interpolate
import TypeScript.Data.Aliases exposing (Aliases)


toTsType : Aliases -> Ast.Expression.Type -> Result String String
toTsType aliases elmType =
    case elmType of
        TypeConstructor [ "List" ] [ listType ] ->
            listTypeString aliases listType

        TypeConstructor [ "Array", "Array" ] [ arrayType ] ->
            listTypeString aliases arrayType

        TypeConstructor [ "Array" ] [ arrayType ] ->
            listTypeString aliases arrayType

        TypeConstructor [ "Maybe" ] [ maybeType ] ->
            toTsType aliases maybeType |> appendStringIfOk " | null"

        TypeConstructor typeName _ ->
            case typeName of
                [ "Json", "Decode", "Value" ] ->
                    Ok "any"

                [ "Decode", "Value" ] ->
                    Ok "any"

                [ "Json", "Encode", "Value" ] ->
                    Ok "any"

                [ "Encode", "Value" ] ->
                    Ok "any"

                primitiveOrAliasTypeName ->
                    primitiveOrTypeAlias aliases primitiveOrAliasTypeName

        TypeTuple [] ->
            Ok "null"

        TypeTuple tupleTypes ->
            tupleTypes
                |> List.map (toTsType aliases)
                |> Result.Extra.combine
                |> Result.map (String.join ", ")
                |> Result.map
                    (\middle ->
                        "["
                            ++ middle
                            ++ "]"
                    )

        TypeRecord recordPairs ->
            recordPairs
                |> List.map (generateRecordPair aliases)
                |> Result.Extra.combine
                |> Result.map (String.join "; ")
                |> Result.map
                    (\middle ->
                        "{ "
                            ++ middle
                            ++ " }"
                    )

        thing ->
            Err ("Unhandled thing: " ++ toString thing)


generateRecordPair : Aliases -> ( String, Ast.Expression.Type ) -> Result String String
generateRecordPair aliases ( recordKey, recordType ) =
    toTsType aliases recordType
        |> Result.map (\value -> recordKey ++ ": " ++ value)


listTypeString : Aliases -> Ast.Expression.Type -> Result String String
listTypeString aliases listType =
    toTsType aliases listType
        |> appendStringIfOk "[]"


appendStringIfOk : String -> Result String String -> Result String String
appendStringIfOk stringToAppend result =
    result |> Result.map (\okResult -> okResult ++ stringToAppend)


primitiveOrTypeAlias : Aliases -> List String -> Result String String
primitiveOrTypeAlias aliases primitiveOrAliasTypeName =
    case primitiveOrAliasTypeName of
        [ singleName ] ->
            case elmPrimitiveToTs singleName of
                Just primitiveNameForTs ->
                    Ok primitiveNameForTs

                Nothing ->
                    lookupAlias aliases [ singleName ]

        listName ->
            lookupAlias aliases listName


lookupAlias : Aliases -> List String -> Result String String
lookupAlias aliases aliasName =
    case
        aliases
            |> lookupAliasEntry aliasName
            |> Maybe.map (toTsType aliases)
    of
        Just foundTsTypeName ->
            foundTsTypeName

        Nothing ->
            [ String.join "." aliasName
            , Dict.keys aliases
                |> List.map (String.join ".")
                |> String.join ", "
            ]
                |> String.Interpolate.interpolate "Alias `{0}` not found. Known aliases:\n{1}"
                |> Err


lookupAliasEntry : List String -> Aliases -> Maybe Ast.Expression.Type
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


elmPrimitiveToTs : String -> Maybe String
elmPrimitiveToTs elmPrimitive =
    case elmPrimitive of
        "String" ->
            Just "string"

        "Int" ->
            Just "number"

        "Float" ->
            Just "number"

        "Bool" ->
            Just "boolean"

        _ ->
            Nothing
