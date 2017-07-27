module Electron.Generator.ElmSerializer exposing (..)

import Electron.Ipc


generateCase : Electron.Ipc.ElmIpc -> String
generateCase something =
    """        ShowFeedbackForm ->
            ( "ShowFeedbackForm", Encode.null )" """
        |> String.trimRight
