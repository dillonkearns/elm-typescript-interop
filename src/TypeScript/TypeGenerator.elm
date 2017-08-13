module TypeScript.TypeGenerator exposing (toTsType)

import Ast.Statement exposing (Type(TypeConstructor, TypeRecord, TypeTuple))
import Dict
import TypeScript.Data.Aliases exposing (Aliases)


toTsType : Aliases -> Ast.Statement.Type -> String
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
                    primitiveOrTypeAlias aliases primitiveOrAliasTypeName

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


generateRecordPair : Aliases -> ( String, Ast.Statement.Type ) -> String
generateRecordPair aliases ( recordKey, recordType ) =
    recordKey ++ ": " ++ toTsType aliases recordType


listTypeString : Aliases -> Ast.Statement.Type -> String
listTypeString aliases listType =
    toTsType aliases listType ++ "[]"


primitiveOrTypeAlias : Aliases -> List String -> String
primitiveOrTypeAlias aliases primitiveOrAliasTypeName =
    case primitiveOrAliasTypeName of
        [ singleName ] ->
            elmPrimitiveToTs singleName
                |> Maybe.withDefault (lookupAlias aliases [ singleName ])

        listName ->
            lookupAlias aliases listName


lookupAlias : Aliases -> List String -> String
lookupAlias aliases aliasName =
    -- ""
    toString <| Dict.fromList [ ( [ "a", "b", "c" ], 123 ) ]



-- "Looking up " ++ toString aliasName ++ " with aliases:\n" ++ toString aliases


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
