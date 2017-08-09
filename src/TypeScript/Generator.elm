module TypeScript.Generator exposing (..)

import TypeScript.Data.Port as Port
import TypeScript.Data.Program as Program


generatePort : Port.Port -> String
generatePort portPort =
    "    hello" ++ """: {
      subscribe(callback: (data: string) => void): void
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
}
    """


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
