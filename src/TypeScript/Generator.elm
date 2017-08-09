module TypeScript.Generator exposing (..)

import Ast.Statement
import TypeScript.Data.ElmType
import TypeScript.Data.Port as Port
import TypeScript.Data.Program as Program


generatePort : Port.Port -> String
generatePort (Port.Port name direction portType) =
    "    " ++ name ++ """: {
      subscribe(callback: (data: """ ++ toTypescriptType portType ++ """) => void): void
    }"""


prefix : String
prefix =
    """// Type definitions for Elm
// Project: https://github.com/dillonkearns/elm-typescript
// Definitions by: Dillon Kearns <https://github.com/dillonkearns>
export as namespace Elm"""


elmModuleNamespace : String
elmModuleNamespace =
    """export namespace Main {
  // TODO: type-safe flags (check if Program Never Model Msg or Program FlagsType Model Msg)
  export function fullscreen(): App
  export function embed(node: HTMLElement | null): App
}"""


generatePorts : List Port.Port -> String
generatePorts ports =
    ports
        |> List.map generatePort
        |> String.join "\n"
        |> wrapPorts


wrapPorts : String -> String
wrapPorts portsString =
    """
export interface App {
  ports: {
"""
        ++ portsString
        ++ """
  }
}
    """


toTypescriptType : Ast.Statement.Type -> String
toTypescriptType payloadType =
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


generate : Program.Program -> String
generate program =
    case program of
        Program.WithFlags flagType ports ->
            "Not implemented"

        Program.WithoutFlags ports ->
            [ prefix
            , generatePorts ports
            , elmModuleNamespace
            ]
                |> String.join "\n\n"
