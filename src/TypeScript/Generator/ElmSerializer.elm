module TypeScript.Generator.ElmSerializer exposing (..)

import TypeScript.Ipc exposing (ElmIpc)


generate : List ElmIpc -> String
generate elmIpcList =
    fileHeader
        ++ (List.map generateCase elmIpcList |> String.join "\n\n")


fileHeader : String
fileHeader =
    """module IpcSerializer exposing (serialize)

import Ipc exposing (Msg(..))
import Json.Encode as Encode


serialize : Msg -> ( String, Encode.Value )
serialize msg =
    case msg of
"""


parameterizedCase : String -> String -> String -> String
parameterizedCase msgName jsonEncodeValue parameterName =
    "        "
        ++ msgName
        ++ " "
        ++ parameterName
        ++ """ ->
            ( \""""
        ++ msgName
        ++ "\", "
        ++ jsonEncodeValue
        ++ " )"


generateCase : TypeScript.Ipc.ElmIpc -> String
generateCase something =
    case something of
        TypeScript.Ipc.Msg msgName ->
            "        "
                ++ msgName
                ++ """ ->
            ( \""""
                ++ msgName
                ++ """", Encode.null )"""

        TypeScript.Ipc.MsgWithData msgName payloadType ->
            case payloadType of
                TypeScript.Ipc.String ->
                    parameterizedCase msgName "Encode.string string" "string"

                TypeScript.Ipc.JsonEncodeValue ->
                    parameterizedCase msgName "value" "value"
