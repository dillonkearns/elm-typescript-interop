module TypeScript.TypeGenerator exposing (toTsType)

import Ast.Statement exposing (..)


toTsType : Ast.Statement.Type -> String
toTsType elmType =
    case elmType of
        TypeConstructor [ "Json", "Decode", "Value" ] [] ->
            "any"

        TypeConstructor [ "Decode", "Value" ] [] ->
            "any"

        TypeConstructor [ "Json", "Encode", "Value" ] [] ->
            "any"

        TypeConstructor [ "Encode", "Value" ] [] ->
            "any"

        Ast.Statement.TypeConstructor [ primitiveType ] [] ->
            elmPrimitiveToTs primitiveType

        Ast.Statement.TypeConstructor [ "Maybe" ] [ maybeType ] ->
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

        TypeConstructor [ "List" ] [ listType ] ->
            listTypeString listType

        TypeConstructor [ "Array", "Array" ] [ arrayType ] ->
            listTypeString arrayType

        TypeConstructor [ "Array" ] [ arrayType ] ->
            listTypeString arrayType

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


elmPrimitiveToTs : String -> String
elmPrimitiveToTs elmPrimitive =
    case elmPrimitive of
        "String" ->
            "string"

        "Int" ->
            "number"

        "Float" ->
            "number"

        "Bool" ->
            "boolean"

        _ ->
            "Unhandled"
