module TypeScript.TypeGenerator exposing (toTsType)

import Ast.Expression exposing (Type(TypeConstructor, TypeRecord, TypeTuple))
import ImportAlias exposing (ImportAlias)
import Result.Extra
import TypeScript.Data.Aliases as Aliases exposing (Aliases)


toTsType : Aliases -> List ImportAlias -> Aliases.LocalTypeDeclarations -> Ast.Expression.Type -> Result String String
toTsType aliases importAliases localTypeDeclarations elmType =
    case elmType of
        TypeConstructor [ "List" ] [ listType ] ->
            listTypeString aliases importAliases localTypeDeclarations listType

        TypeConstructor [ "Array", "Array" ] [ arrayType ] ->
            listTypeString aliases importAliases localTypeDeclarations arrayType

        TypeConstructor [ "Array" ] [ arrayType ] ->
            listTypeString aliases importAliases localTypeDeclarations arrayType

        TypeConstructor [ "Maybe" ] [ maybeType ] ->
            toTsType aliases importAliases localTypeDeclarations maybeType |> appendStringIfOk " | null"

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
                    primitiveOrTypeAlias aliases importAliases localTypeDeclarations primitiveOrAliasTypeName

        TypeTuple [] ->
            Ok "null"

        TypeTuple tupleTypes ->
            tupleTypes
                |> List.map (toTsType aliases importAliases localTypeDeclarations)
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
                |> List.map (generateRecordPair aliases importAliases localTypeDeclarations)
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


generateRecordPair : Aliases -> List ImportAlias -> Aliases.LocalTypeDeclarations -> ( String, Ast.Expression.Type ) -> Result String String
generateRecordPair aliases importAliases localTypeDeclarations ( recordKey, recordType ) =
    toTsType aliases importAliases localTypeDeclarations recordType
        |> Result.map (\value -> recordKey ++ ": " ++ value)


listTypeString : Aliases -> List ImportAlias -> Aliases.LocalTypeDeclarations -> Ast.Expression.Type -> Result String String
listTypeString aliases importAliases localTypeDeclarations listType =
    toTsType aliases importAliases localTypeDeclarations listType
        |> appendStringIfOk "[]"


appendStringIfOk : String -> Result String String -> Result String String
appendStringIfOk stringToAppend result =
    result |> Result.map (\okResult -> okResult ++ stringToAppend)


primitiveOrTypeAlias : Aliases -> List ImportAlias -> Aliases.LocalTypeDeclarations -> List String -> Result String String
primitiveOrTypeAlias aliases importAliases localTypeDeclarations primitiveOrAliasTypeName =
    case elmPrimitiveToTs primitiveOrAliasTypeName of
        Just primitiveNameForTs ->
            Ok primitiveNameForTs

        Nothing ->
            case Aliases.lookupAlias aliases (Aliases.unqualifiedTypeReference localTypeDeclarations primitiveOrAliasTypeName importAliases) of
                Ok foundAliasExpression ->
                    toTsType aliases importAliases localTypeDeclarations foundAliasExpression

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
