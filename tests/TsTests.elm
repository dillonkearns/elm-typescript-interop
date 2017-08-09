module TsTests exposing (..)

import Expect
import Test exposing (Test, describe, test)
import TypeScript.Generator
import TypeScript.Parser


suite : Test
suite =
    describe "ts"
        [ test "interface for msg with no parameters" <|
            \() ->
                TypeScript.Parser.Msg "HideWindow"
                    |> TypeScript.Generator.generateInterface
                    |> Expect.equal
                        "interface HideWindow {\n  message: 'HideWindow'\n}"
        , test "another interface for msg with no parameters" <|
            \() ->
                TypeScript.Parser.Msg "MakeItSo"
                    |> TypeScript.Generator.generateInterface
                    |> Expect.equal
                        "interface MakeItSo {\n  message: 'MakeItSo'\n}"
        , test "interface with Json.Encode.Value parameter" <|
            \() ->
                TypeScript.Parser.MsgWithData "UploadSchematic" TypeScript.Parser.JsonEncodeValue
                    |> TypeScript.Generator.generateInterface
                    |> Expect.equal
                        ("""
interface UploadSchematic {
  message: 'UploadSchematic'
  data: any
}
                        """ |> String.trim)
        , test "interface with parameters" <|
            \() ->
                TypeScript.Parser.MsgWithData "SetPhasersTo" TypeScript.Parser.String
                    |> TypeScript.Generator.generateInterface
                    |> Expect.equal
                        ("""
interface SetPhasersTo {
  message: 'SetPhasersTo'
  data: string
}
""" |> String.trim)
        , test "union" <|
            \() ->
                [ TypeScript.Parser.Msg "HideWindow" ]
                    |> TypeScript.Generator.generateUnion
                    |> Expect.equal
                        "type ElmIpc = HideWindow"
        , test "union with multiple types" <|
            \() ->
                [ TypeScript.Parser.Msg "Engage"
                , TypeScript.Parser.MsgWithData "UploadSchematic" TypeScript.Parser.JsonEncodeValue
                , TypeScript.Parser.MsgWithData "SetPhasersTo" TypeScript.Parser.String
                ]
                    |> TypeScript.Generator.generateUnion
                    |> Expect.equal
                        "type ElmIpc = Engage | UploadSchematic | SetPhasersTo"
        ]
