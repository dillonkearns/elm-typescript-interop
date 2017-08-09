module TypeScript.Generator exposing (..)

import TypeScript.Parser


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


generate : List TypeScript.Parser.ElmIpc -> String
generate msgs =
    [ prefix
    , generateUnion msgs
    , msgs |> List.map generateInterface |> String.join "\n\n"
    ]
        |> String.join "\n\n"


generateInterface : TypeScript.Parser.ElmIpc -> String
generateInterface elmIpc =
    case elmIpc of
        TypeScript.Parser.Msg msgName ->
            "interface " ++ msgName ++ " {\n  message: '" ++ msgName ++ "'\n}"

        TypeScript.Parser.MsgWithData msgName parameterType ->
            "interface "
                ++ msgName
                ++ " {\n  message: '"
                ++ msgName
                ++ "'\n  data: "
                ++ toTypescriptType parameterType
                ++ "\n}"


toTypescriptType : TypeScript.Parser.PayloadType -> String
toTypescriptType payloadType =
    case payloadType of
        TypeScript.Parser.String ->
            "string"

        TypeScript.Parser.JsonEncodeValue ->
            "any"


generateUnion : List TypeScript.Parser.ElmIpc -> String
generateUnion ipcList =
    "type ElmIpc = "
        ++ (ipcList
                |> List.map ipcName
                |> String.join " | "
           )


ipcName : TypeScript.Parser.ElmIpc -> String
ipcName elmIpc =
    case elmIpc of
        TypeScript.Parser.Msg msgName ->
            msgName

        TypeScript.Parser.MsgWithData msgName payloadType ->
            msgName
