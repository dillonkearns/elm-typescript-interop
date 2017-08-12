module TypeScript.TypeGenerator exposing (toTsType)

import Ast.Statement


toTsType : Ast.Statement.Type -> String
toTsType elmType =
    case elmType of
        Ast.Statement.TypeConstructor [ primitiveType ] [] ->
            elmPrimitiveToTs primitiveType

        Ast.Statement.TypeConstructor [ "Maybe" ] [ maybeType ] ->
            toTsType maybeType ++ " | null"

        _ ->
            "Unhandled"


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
