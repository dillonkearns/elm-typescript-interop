module TypeScript.Generator.Ts exposing (..)

import TypeScript.Ipc


prefix : String
prefix =
    """
import { ipcMain } from 'typescript'

class Ipc {
  static setupIpcMessageHandler(onIpcMessage: (elmIpc: ElmIpc) => any) {
    ipcMain.on('elm-typescript-ipc', (event: any, payload: any) => {
      onIpcMessage(payload)
    })
  }
}

export { Ipc, ElmIpc }
    """


generate : List TypeScript.Ipc.ElmIpc -> String
generate msgs =
    [ prefix
    , generateUnion msgs
    , msgs |> List.map generateInterface |> String.join "\n\n"
    ]
        |> String.join "\n\n"


generateInterface : TypeScript.Ipc.ElmIpc -> String
generateInterface elmIpc =
    case elmIpc of
        TypeScript.Ipc.Msg msgName ->
            "interface " ++ msgName ++ " {\n  message: '" ++ msgName ++ "'\n}"

        TypeScript.Ipc.MsgWithData msgName parameterType ->
            "interface "
                ++ msgName
                ++ " {\n  message: '"
                ++ msgName
                ++ "'\n  data: "
                ++ toTypescriptType parameterType
                ++ "\n}"


toTypescriptType : TypeScript.Ipc.PayloadType -> String
toTypescriptType payloadType =
    case payloadType of
        TypeScript.Ipc.String ->
            "string"

        TypeScript.Ipc.JsonEncodeValue ->
            "any"


generateUnion : List TypeScript.Ipc.ElmIpc -> String
generateUnion ipcList =
    "type ElmIpc = "
        ++ (ipcList
                |> List.map ipcName
                |> String.join " | "
           )


ipcName : TypeScript.Ipc.ElmIpc -> String
ipcName elmIpc =
    case elmIpc of
        TypeScript.Ipc.Msg msgName ->
            msgName

        TypeScript.Ipc.MsgWithData msgName payloadType ->
            msgName
