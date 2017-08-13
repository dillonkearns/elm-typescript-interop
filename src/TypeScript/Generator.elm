module TypeScript.Generator exposing (..)

import Ast.Statement
import TypeScript.Data.Alias exposing (Alias)
import TypeScript.Data.Port as Port
import TypeScript.Data.Program as Program
import TypeScript.TypeGenerator exposing (toTsType)


generatePort : List Alias -> Port.Port -> String
generatePort aliases (Port.Port name direction portType) =
    let
        inner =
            case direction of
                Port.Outbound ->
                    "subscribe(callback: (data: " ++ toTsType aliases portType ++ ") => void)"

                Port.Inbound ->
                    "send(data: " ++ toTsType aliases portType ++ ")"
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


elmModuleNamespace : List Alias -> Maybe Ast.Statement.Type -> String
elmModuleNamespace aliases maybeFlagsType =
    let
        fullscreenParam =
            maybeFlagsType
                |> Maybe.map (toTsType aliases)
                |> Maybe.map (\tsType -> "flags: " ++ tsType)
                |> Maybe.withDefault ""

        embedAppendParam =
            case maybeFlagsType of
                Nothing ->
                    ""

                Just flagsType ->
                    ", flags: " ++ toTsType aliases flagsType
    in
    """export namespace Main {
  export function fullscreen(""" ++ fullscreenParam ++ """): App
  export function embed(node: HTMLElement | null""" ++ embedAppendParam ++ """): App
}"""


generatePorts : List Alias -> List Port.Port -> String
generatePorts aliases ports =
    ports
        |> List.map (generatePort aliases)
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
        Program.ElmProgram flagsType aliases ports ->
            [ prefix
            , generatePorts aliases ports
            , elmModuleNamespace aliases flagsType
            ]
                |> String.join "\n\n"
