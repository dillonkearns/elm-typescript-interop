module TypeScript.TypeGenerator exposing (toTsType)

import Ast.Statement


toTsType : Ast.Statement.Type -> String
toTsType elmType =
    case elmType of
        Ast.Statement.TypeConstructor [ primitiveType ] [] ->
            elmPrimitiveToTs primitiveType

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
