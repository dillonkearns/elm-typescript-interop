module TypeScript.TypeGenerator exposing (toTsType)

import Ast.Expression exposing (Type(TypeConstructor, TypeRecord, TypeTuple))
import Parser.Context exposing (Context)
import Result.Extra
import TypeScript.Data.Aliases as Aliases exposing (Aliases)


toTsType : Context -> Aliases -> Ast.Expression.Type -> Result String String
toTsType context aliases elmType =
    case elmType of
        TypeConstructor [ "List" ] [ listType ] ->
            listTypeString context aliases listType

        TypeConstructor [ "Array", "Array" ] [ arrayType ] ->
            listTypeString context aliases arrayType

        TypeConstructor [ "Array" ] [ arrayType ] ->
            listTypeString context aliases arrayType

        TypeConstructor [ "Maybe" ] [ maybeType ] ->
            toTsType context aliases maybeType |> appendStringIfOk " | null"

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
                    primitiveOrTypeAlias context aliases primitiveOrAliasTypeName

        TypeTuple [] ->
            Ok "null"

        TypeTuple tupleTypes ->
            tupleTypes
                |> List.map (toTsType context aliases)
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
                |> List.map (generateRecordPair context aliases)
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


generateRecordPair : Context -> Aliases -> ( String, Ast.Expression.Type ) -> Result String String
generateRecordPair context aliases ( recordKey, recordType ) =
    toTsType context aliases recordType
        |> Result.map (\value -> recordKey ++ ": " ++ value)


listTypeString : Context -> Aliases -> Ast.Expression.Type -> Result String String
listTypeString context aliases listType =
    toTsType context aliases listType
        |> appendStringIfOk "[]"


appendStringIfOk : String -> Result String String -> Result String String
appendStringIfOk stringToAppend result =
    result |> Result.map (\okResult -> okResult ++ stringToAppend)


primitiveOrTypeAlias : Context -> Aliases -> List String -> Result String String
primitiveOrTypeAlias context aliases primitiveOrAliasTypeName =
    case elmPrimitiveToTs primitiveOrAliasTypeName of
        Just primitiveNameForTs ->
            Ok primitiveNameForTs

        Nothing ->
            case Aliases.lookupAlias aliases (Aliases.unqualifiedTypeReference context primitiveOrAliasTypeName) of
                Ok foundAliasExpression ->
                    toTsType context aliases foundAliasExpression

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
