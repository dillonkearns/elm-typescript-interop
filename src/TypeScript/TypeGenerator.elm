module TypeScript.TypeGenerator exposing (toTsType)

import Ast.Statement
import TypeScript.Data.ElmType


toTsType : Ast.Statement.Type -> String
toTsType payloadType =
    case toElmType payloadType of
        TypeScript.Data.ElmType.String ->
            "string"

        TypeScript.Data.ElmType.Int ->
            "number"

        TypeScript.Data.ElmType.Float ->
            "number"

        TypeScript.Data.ElmType.Bool ->
            "boolean"


toElmType : Ast.Statement.Type -> TypeScript.Data.ElmType.ElmType
toElmType payloadType =
    case payloadType of
        Ast.Statement.TypeConstructor [ primitiveType ] [] ->
            case primitiveType of
                "String" ->
                    TypeScript.Data.ElmType.String

                "Int" ->
                    TypeScript.Data.ElmType.Int

                "Float" ->
                    TypeScript.Data.ElmType.Float

                "Bool" ->
                    TypeScript.Data.ElmType.Bool

                _ ->
                    TypeScript.Data.ElmType.String

        _ ->
            TypeScript.Data.ElmType.String
