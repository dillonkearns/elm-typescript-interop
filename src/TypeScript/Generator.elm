module TypeScript.Generator exposing (..)

import Ast.Statement
import TypeScript.Data.ElmType
import TypeScript.Data.Port as Port
import TypeScript.Data.Program as Program
import TypeScript.TypeGenerator exposing (toTsType)


generatePort : Port.Port -> String
generatePort (Port.Port name direction portType) =
    let
        inner =
            case direction of
                Port.Outbound ->
                    "subscribe(callback: (data: " ++ toTsType portType ++ ") => void)"

                Port.Inbound ->
                    "send(data: " ++ toTsType portType ++ ")"
    in
    "    " ++ name ++ """: {
      """ ++ inner ++ """: void
    }"""


prefix : String
prefix =
    """// Type definitions for Elm
// Project: https://github.com/dillonkearns/elm-typescript
// Definitions by: Dillon Kearns <https://github.com/dillonkearns>
export as namespace Elm"""


elmModuleNamespace : Maybe Ast.Statement.Type -> String
elmModuleNamespace maybeFlagsType =
    let
        fullscreenParam =
            maybeFlagsType
                |> Maybe.map toTsType
                |> Maybe.map (\tsType -> "flags: " ++ tsType)
                |> Maybe.withDefault ""

        embedAppendParam =
            case maybeFlagsType of
                Nothing ->
                    ""

                Just flagsType ->
                    ", flags: " ++ toTsType flagsType
    in
    """export namespace Main {
  export function fullscreen(""" ++ fullscreenParam ++ """): App
  export function embed(node: HTMLElement | null""" ++ embedAppendParam ++ """): App
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


generate : Program.Program -> String
generate program =
    case program of
        Program.ElmProgram flagsType ports ->
            [ prefix
            , generatePorts ports
            , elmModuleNamespace flagsType
            ]
                |> String.join "\n\n"
