module ParserTests exposing (..)

import Expect exposing (Expectation)
import Test exposing (..)
import TypeScript.Parser


suite : Test
suite =
    describe "parser"
        [ test "single type with no data" <|
            \_ ->
                """
                  module Ipc exposing (..)

                  import Json.Encode as Encode


                  type Msg
                      = HideWindow
                """
                    |> TypeScript.Parser.toTypes
                    |> Expect.equal (Ok [ TypeScript.Parser.Msg "HideWindow" ])
        , test "another single type with no data" <|
            \_ ->
                """
                              module Ipc exposing (..)

                              import Json.Encode as Encode

                              type Msg
                                  = Quit
                            """
                    |> TypeScript.Parser.toTypes
                    |> Expect.equal (Ok [ TypeScript.Parser.Msg "Quit" ])
        , test "a single type with a String param" <|
            \_ ->
                """
                  module Ipc exposing (..)

                  type Msg
                      = Replicate String
                """
                    |> TypeScript.Parser.toTypes
                    |> Expect.equal (Ok [ TypeScript.Parser.MsgWithData "Replicate" TypeScript.Parser.String ])
        , test "reports errors for unsupported types" <|
            \_ ->
                """
                                          module Ipc exposing (..)

                                          type Msg
                                              = Transport Banana
                                        """
                    |> TypeScript.Parser.toTypes
                    |> Expect.equal
                        (Err "Unsupported parameter type for Transport constructor: Banana")
        , test "multiple types with a String params" <|
            \_ ->
                """
                                                          module Ipc exposing (..)

                                                          type Msg
                                                              = Transport String
                                                              | SetPhasersTo String
                                                        """
                    |> TypeScript.Parser.toTypes
                    |> Expect.equal
                        (Ok
                            [ TypeScript.Parser.MsgWithData "Transport" TypeScript.Parser.String
                            , TypeScript.Parser.MsgWithData "SetPhasersTo" TypeScript.Parser.String
                            ]
                        )
        , test "multiple types with a Json.Encode params" <|
            \_ ->
                """
                              module Ipc exposing (..)

                              type Msg
                                  = Transport Encode.Value
                                  | UploadSchematic Encode.Value
                            """
                    |> TypeScript.Parser.toTypes
                    |> Expect.equal
                        (Ok
                            [ TypeScript.Parser.MsgWithData "Transport" TypeScript.Parser.JsonEncodeValue
                            , TypeScript.Parser.MsgWithData "UploadSchematic" TypeScript.Parser.JsonEncodeValue
                            ]
                        )
        ]
