module TypeScript.TypeGenerator exposing (toTsType)

import Ast.Statement exposing (Type(TypeConstructor, TypeRecord, TypeTuple))


toTsType : Ast.Statement.Type -> String
toTsType elmType =
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
            listTypeString listType

        TypeConstructor [ "Array", "Array" ] [ arrayType ] ->
            listTypeString arrayType

        TypeConstructor [ "Array" ] [ arrayType ] ->
            listTypeString arrayType

        TypeConstructor [ "Maybe" ] [ maybeType ] ->
            toTsType maybeType ++ " | null"

        TypeTuple [] ->
            "null"

        TypeTuple tupleTypes ->
            "["
                ++ (tupleTypes
                        |> List.map toTsType
                        |> String.join ", "
                   )
                ++ "]"

        TypeRecord recordPairs ->
            let
                something =
                    recordPairs
                        |> List.map generateRecordPair
                        |> String.join "; "
            in
            "{ "
                ++ something
                ++ " }"

        _ ->
            "Unhandled"


generateRecordPair : ( String, Ast.Statement.Type ) -> String
generateRecordPair ( recordKey, recordType ) =
    recordKey ++ ": " ++ toTsType recordType


listTypeString : Ast.Statement.Type -> String
listTypeString listType =
    toTsType listType ++ "[]"


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
