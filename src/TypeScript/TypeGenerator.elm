module TypeScript.TypeGenerator exposing (toTsType)

import Ast.Statement exposing (Type(TypeConstructor, TypeRecord, TypeTuple))
import TypeScript.Data.Alias exposing (Alias)


toTsType : List Alias -> Ast.Statement.Type -> String
toTsType aliases elmType =
    case elmType of
        TypeConstructor typeName [] ->
            case typeName of
                [ "Json", "Decode", "Value" ] ->
                    "any"

                [ "Decode", "Value" ] ->
                    "any"

                [ "Json", "Encode", "Value" ] ->
                    "any"

                [ "Encode", "Value" ] ->
                    "any"

                primitiveOrAliasTypeName ->
                    primitiveOrTypeAlias primitiveOrAliasTypeName

        TypeConstructor [ "List" ] [ listType ] ->
            listTypeString aliases listType

        TypeConstructor [ "Array", "Array" ] [ arrayType ] ->
            listTypeString aliases arrayType

        TypeConstructor [ "Array" ] [ arrayType ] ->
            listTypeString aliases arrayType

        TypeConstructor [ "Maybe" ] [ maybeType ] ->
            toTsType aliases maybeType ++ " | null"

        TypeTuple [] ->
            "null"

        TypeTuple tupleTypes ->
            "["
                ++ (tupleTypes
                        |> List.map (toTsType aliases)
                        |> String.join ", "
                   )
                ++ "]"

        TypeRecord recordPairs ->
            let
                something =
                    recordPairs
                        |> List.map (generateRecordPair aliases)
                        |> String.join "; "
            in
            "{ "
                ++ something
                ++ " }"

        _ ->
            "Unhandled"


generateRecordPair : List Alias -> ( String, Ast.Statement.Type ) -> String
generateRecordPair aliases ( recordKey, recordType ) =
    recordKey ++ ": " ++ toTsType aliases recordType


listTypeString : List Alias -> Ast.Statement.Type -> String
listTypeString aliases listType =
    toTsType aliases listType ++ "[]"


primitiveOrTypeAlias : List String -> String
primitiveOrTypeAlias primitiveOrAliasTypeName =
    case primitiveOrAliasTypeName of
        [ singleName ] ->
            elmPrimitiveToTs singleName
                |> Maybe.withDefault (lookupAlias [ singleName ])

        listName ->
            lookupAlias listName


lookupAlias : List String -> String
lookupAlias aliasName =
    ""


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
