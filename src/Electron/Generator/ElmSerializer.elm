module Electron.Generator.ElmSerializer exposing (..)

import Electron.Ipc exposing (ElmIpc)


generate : List ElmIpc -> String
generate elmIpcList =
    fileHeader
        ++ (List.map generateCase elmIpcList |> String.join "\n\n")


fileHeader : String
fileHeader =
    """module IpcSerializer exposing (serialize)

import Json.Encode.Value as Encode


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


generateCase : Electron.Ipc.ElmIpc -> String
generateCase something =
    case something of
        Electron.Ipc.Msg msgName ->
            "        "
                ++ msgName
                ++ """ ->
            ( \""""
                ++ msgName
                ++ """", Encode.null )"""

        Electron.Ipc.MsgWithData msgName payloadType ->
            -- """        Transport string ->
            -- ( "Transport", Encode.string string )"""
            parameterizedCase msgName "Encode.string string" "string"
