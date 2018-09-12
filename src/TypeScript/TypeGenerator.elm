module TypeScript.TypeGenerator exposing (toTsType)

import Ast.Expression exposing (Type(TypeConstructor, TypeRecord, TypeTuple))
import Result.Extra
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
                    Ok "unknown"

                [ "Decode", "Value" ] ->
                    Ok "unknown"

                [ "Json", "Encode", "Value" ] ->
                    Ok "unknown"

                [ "Encode", "Value" ] ->
                    Ok "unknown"

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
                    case TypeScript.Data.Aliases.lookupAlias aliases [ singleName ] of
                        Ok foundAliasExpression ->
                            toTsType aliases foundAliasExpression

                        Err errorString ->
                            Err errorString

        listName ->
            case TypeScript.Data.Aliases.lookupAlias aliases listName of
                Ok foundAliasExpression ->
                    toTsType aliases foundAliasExpression

                Err errorString ->
                    Err errorString


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
