module Electron.Generator.Ts exposing (..)

import Electron.Ipc


generateInterface : Electron.Ipc.ElmIpc -> String
generateInterface something =
    "interface HideWindow {\n  message: 'HideWindow'\n}"
