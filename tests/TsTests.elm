module TsTests exposing (..)

import Expect
import Test exposing (Test, describe, test)
import TypeScript.Generator.Ts
import TypeScript.Ipc


suite : Test
suite =
    describe "ts"
        [ test "interface for msg with no parameters" <|
            \() ->
                TypeScript.Ipc.Msg "HideWindow"
                    |> TypeScript.Generator.Ts.generateInterface
                    |> Expect.equal
                        "interface HideWindow {\n  message: 'HideWindow'\n}"
        , test "another interface for msg with no parameters" <|
            \() ->
                TypeScript.Ipc.Msg "MakeItSo"
                    |> TypeScript.Generator.Ts.generateInterface
                    |> Expect.equal
                        "interface MakeItSo {\n  message: 'MakeItSo'\n}"
        , test "interface with Json.Encode.Value parameter" <|
            \() ->
                TypeScript.Ipc.MsgWithData "UploadSchematic" TypeScript.Ipc.JsonEncodeValue
                    |> TypeScript.Generator.Ts.generateInterface
                    |> Expect.equal
                        ("""
interface UploadSchematic {
  message: 'UploadSchematic'
  data: any
}
                        """ |> String.trim)
        , test "interface with parameters" <|
            \() ->
                TypeScript.Ipc.MsgWithData "SetPhasersTo" TypeScript.Ipc.String
                    |> TypeScript.Generator.Ts.generateInterface
                    |> Expect.equal
                        ("""
interface SetPhasersTo {
  message: 'SetPhasersTo'
  data: string
}
""" |> String.trim)
        , test "union" <|
            \() ->
                [ TypeScript.Ipc.Msg "HideWindow" ]
                    |> TypeScript.Generator.Ts.generateUnion
                    |> Expect.equal
                        "type ElmIpc = HideWindow"
        , test "union with multiple types" <|
            \() ->
                [ TypeScript.Ipc.Msg "Engage"
                , TypeScript.Ipc.MsgWithData "UploadSchematic" TypeScript.Ipc.JsonEncodeValue
                , TypeScript.Ipc.MsgWithData "SetPhasersTo" TypeScript.Ipc.String
                ]
                    |> TypeScript.Generator.Ts.generateUnion
                    |> Expect.equal
                        "type ElmIpc = Engage | UploadSchematic | SetPhasersTo"
        ]
