module TypeScript.Generator exposing (..)

import TypeScript.Data.Aliases exposing (Aliases)
import TypeScript.Data.Port as Port
import TypeScript.Data.Program as Program exposing (Main)
import TypeScript.TypeGenerator exposing (toTsType)


generatePort : Aliases -> Port.Port -> String
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


elmModuleNamespace : Aliases -> Main -> String
elmModuleNamespace aliases main =
    let
        fullscreenParam =
            main.flagsType
                |> Maybe.map (toTsType aliases)
                |> Maybe.map (\tsType -> "flags: " ++ tsType)
                |> Maybe.withDefault ""

        moduleName =
            String.join "." main.moduleName

        embedAppendParam =
            case main.flagsType of
                Nothing ->
                    ""

                Just flagsType ->
                    ", flags: " ++ toTsType aliases flagsType
    in
    "export namespace " ++ moduleName ++ """ {
  export function fullscreen(""" ++ fullscreenParam ++ """): App
  export function embed(node: HTMLElement | null""" ++ embedAppendParam ++ """): App
}"""


generatePorts : Aliases -> List Port.Port -> String
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
        Program.ElmProgram main aliases ports ->
            [ prefix
            , generatePorts aliases ports
            , elmModuleNamespace aliases (main |> Maybe.withDefault { moduleName = [ "NOT FOUND" ], flagsType = Nothing })
            ]
                |> String.join "\n\n"
