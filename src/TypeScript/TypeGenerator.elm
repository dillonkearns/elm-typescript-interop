module TypeScript.TypeGenerator exposing (toTsType)

import Ast.Expression exposing (Type(TypeConstructor, TypeRecord, TypeTuple))
import ImportAlias exposing (ImportAlias)
import Result.Extra
import TypeScript.Data.Aliases as Aliases exposing (Aliases)


toTsType : Aliases -> List ImportAlias -> Ast.Expression.Type -> Result String String
toTsType aliases importAliases elmType =
    case elmType of
        TypeConstructor [ "List" ] [ listType ] ->
            listTypeString aliases importAliases listType

        TypeConstructor [ "Array", "Array" ] [ arrayType ] ->
            listTypeString aliases importAliases arrayType

        TypeConstructor [ "Array" ] [ arrayType ] ->
            listTypeString aliases importAliases arrayType

        TypeConstructor [ "Maybe" ] [ maybeType ] ->
            toTsType aliases importAliases maybeType |> appendStringIfOk " | null"

        TypeConstructor typeName _ ->
            case typeName of
                [ "Json", "Decode", "Value" ] ->
                    Ok "unknown"

                [ "Decode", "Value" ] ->
                    Ok "unknown"

                [ "Json", "Encode", "Value" ] ->
                    Ok "unknown"

                [ "Encode", "Value" ] ->
                    Ok "unknown"

                primitiveOrAliasTypeName ->
                    primitiveOrTypeAlias aliases importAliases primitiveOrAliasTypeName

        TypeTuple [] ->
            Ok "null"

        TypeTuple tupleTypes ->
            tupleTypes
                |> List.map (toTsType aliases importAliases)
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
                |> List.map (generateRecordPair aliases importAliases)
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


generateRecordPair : Aliases -> List ImportAlias -> ( String, Ast.Expression.Type ) -> Result String String
generateRecordPair aliases importAliases ( recordKey, recordType ) =
    toTsType aliases importAliases recordType
        |> Result.map (\value -> recordKey ++ ": " ++ value)


listTypeString : Aliases -> List ImportAlias -> Ast.Expression.Type -> Result String String
listTypeString aliases importAliases listType =
    toTsType aliases importAliases listType
        |> appendStringIfOk "[]"


appendStringIfOk : String -> Result String String -> Result String String
appendStringIfOk stringToAppend result =
    result |> Result.map (\okResult -> okResult ++ stringToAppend)


primitiveOrTypeAlias : Aliases -> List ImportAlias -> List String -> Result String String
primitiveOrTypeAlias aliases importAliases primitiveOrAliasTypeName =
    case elmPrimitiveToTs primitiveOrAliasTypeName of
        Just primitiveNameForTs ->
            Ok primitiveNameForTs

        Nothing ->
            case Aliases.lookupAlias aliases (Aliases.unqualifiedTypeReference primitiveOrAliasTypeName importAliases) of
                Ok foundAliasExpression ->
                    toTsType aliases importAliases foundAliasExpression

                Err errorString ->
                    Err errorString


elmPrimitiveToTs : List String -> Maybe String
elmPrimitiveToTs elmPrimitive =
    case elmPrimitive of
        [ "String" ] ->
            Just "string"

        [ "Int" ] ->
            Just "number"

        [ "Float" ] ->
            Just "number"

        [ "Bool" ] ->
            Just "boolean"

        _ ->
            Nothing
