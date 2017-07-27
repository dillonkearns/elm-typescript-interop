module Electron.Generator.Ts exposing (..)

import Electron.Ipc


prefix : String
prefix =
    """
import { ipcMain } from 'electron'

class Ipc {
  static setupIpcMessageHandler(onIpcMessage: (elmIpc: ElmIpc) => any) {
    ipcMain.on('elm-electron-ipc', (event: any, payload: any) => {
      onIpcMessage(payload)
    })
  }
}

export { Ipc, ElmIpc }
    """


generate : List Electron.Ipc.ElmIpc -> String
generate msgs =
    [ prefix
    , generateUnion msgs
    , msgs |> List.map generateInterface |> String.join "\n\n"
    ]
        |> String.join "\n\n"


generateInterface : Electron.Ipc.ElmIpc -> String
generateInterface elmIpc =
    case elmIpc of
        Electron.Ipc.Msg msgName ->
            "interface " ++ msgName ++ " {\n  message: '" ++ msgName ++ "'\n}"

        Electron.Ipc.MsgWithData string payloadType ->
            "TODO"


generateUnion : List Electron.Ipc.ElmIpc -> String
generateUnion elmIpcIpcElectronList =
    "type ElmIpc =\n | ShowFeedbackForm"
