module Electron.Generator.ElmSerializer exposing (..)

import Electron.Ipc exposing (ElmIpc)


generate : List ElmIpc -> String
generate elmIpcList =
    fileHeader
        ++ (List.map generateCase elmIpcList |> String.join "\n\n")


fileHeader : String
fileHeader =
    """module IpcSerializer exposing (serialize)


serialize : Msg -> ( String, Encode.Value )
serialize msg =
    case msg of
"""


generateCase : Electron.Ipc.ElmIpc -> String
generateCase something =
    """        ShowFeedbackForm ->
            ( "ShowFeedbackForm", Encode.null )" """
        |> String.trimRight
