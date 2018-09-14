module TypeScript.Generator exposing (elmModuleNamespace, generate, generatePort, generatePorts, prefix, wrapPorts)

import ElmProjectConfig exposing (ElmVersion)
import OutputPath
import Result.Extra
import String.Interpolate exposing (interpolate)
import TypeScript.Data.Aliases exposing (Aliases)
import TypeScript.Data.Port as Port
import TypeScript.Data.Program as Program exposing (Main)
import TypeScript.TypeGenerator exposing (toTsType)


generatePort : Aliases -> Port.Port -> Result String String
generatePort aliases (Port.Port name direction portType) =
    (case direction of
        Port.Outbound ->
            toTsType aliases [] portType
                |> Result.map
                    (\tsType -> "subscribe(callback: (data: " ++ tsType ++ ") => void)")

        Port.Inbound ->
            toTsType aliases [] portType
                |> Result.map (\tsType -> "send(data: " ++ tsType ++ ")")
    )
        |> Result.map
            (\inner ->
                String.Interpolate.interpolate
                    """{0}: {
  {1}: void
}"""
                    [ name, inner ]
            )


prefix : String
prefix =
    """// WARNING: Do not manually modify this file. It was generated using:
// https://github.com/dillonkearns/elm-typescript-interop
// Type definitions for Elm ports"""


elmModuleNamespace : ElmVersion -> String -> Aliases -> Main -> Result String String
elmModuleNamespace elmVersion portsString aliases main =
    let
        fullscreenParamResult =
            case main.flagsType of
                Nothing ->
                    Ok ""

                Just flagsType ->
                    toTsType aliases [] flagsType
                        |> Result.map
                            (\flagsTsType -> "flags: " ++ flagsTsType)

        moduleName =
            String.join "." main.moduleName

        embedAppendParamResult =
            case main.flagsType of
                Nothing ->
                    Ok ""

                Just flagsType ->
                    toTsType aliases [] flagsType
                        |> Result.map (\tsFlagsType -> ", flags: " ++ tsFlagsType)
    in
    case ( embedAppendParamResult, fullscreenParamResult ) of
        ( Ok embedAppendParam, Ok fullscreenParam ) ->
            case elmVersion of
                ElmProjectConfig.Elm18 ->
                    interpolate """export namespace {0} {
  export interface App {
    ports: {
{3}
    };
  }

  export function fullscreen({1}): {0}.App;
  export function embed(node: HTMLElement | null{2}): {0}.App;
}"""
                        [ moduleName
                        , fullscreenParam
                        , embedAppendParam
                        , portsString
                            |> indented 3
                        ]
                        |> Ok

                ElmProjectConfig.Elm19 ->
                    interpolate """export namespace Elm {
  namespace {0} {
    export interface App {
      ports: {
{3}
      };
    }
    export function init(options: {
      node?: HTMLElement | null;
      {1};
    }): Elm.{0}.App;
  }
}"""
                        [ moduleName
                        , fullscreenParam
                        , embedAppendParam
                        , portsString
                            |> indented 4
                        ]
                        |> Ok

        ( result1, result2 ) ->
            Result.Extra.combine [ result1, result2 ]
                |> Result.map (\_ -> "")


generatePorts : Aliases -> List Port.Port -> Result String String
generatePorts aliases ports =
    ports
        |> List.map (generatePort aliases)
        |> Result.Extra.combine
        |> Result.map (String.join "\n")
        |> Result.map wrapPorts


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


type alias FileToGenerate =
    { path : String, contents : String }


generate : ElmVersion -> Program.Program -> Result String (List FileToGenerate)
generate elmVersion (Program.ElmProgram mains aliases ports) =
    mains
        |> List.map
            (\main ->
                generateSingle elmVersion main aliases ports
                    |> Result.map
                        (\contents ->
                            { path = main.filePath |> OutputPath.declarationPathFromMainElmPath
                            , contents = contents
                            }
                        )
            )
        |> Result.Extra.combine


generateSingle :
    ElmVersion
    -> Main
    -> Aliases
    -> List Port.Port
    -> Result String String
generateSingle elmVersion main aliases ports =
    let
        portsResult =
            ports
                |> List.map (generatePort aliases)
                |> Result.Extra.combine
                |> Result.map (String.join "\n")
    in
    case
        [ Ok prefix
        , portsResult |> Result.andThen (\portsString -> elmModuleNamespace elmVersion portsString aliases main)
        ]
            |> Result.Extra.combine
    of
        Ok list ->
            list
                |> String.join "\n\n"
                |> Ok

        Err errorMessage ->
            Err errorMessage


indented : Int -> String -> String
indented amount code =
    code
        |> String.split "\n"
        |> List.map (\line -> indentation amount ++ line)
        |> String.join "\n"


indentation : Int -> String
indentation n =
    if n == 0 then
        ""

    else
        "  " ++ indentation (n - 1)
