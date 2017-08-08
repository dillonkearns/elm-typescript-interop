module IpcTests exposing (..)

import TypeScript.Ipc
import Expect exposing (Expectation)
import Test exposing (..)


suite : Test
suite =
    describe "parsers"
        [ test "single type with no data" <|
            \_ ->
                """
                  module Ipc exposing (..)

                  import Json.Encode as Encode


                  type Msg
                      = HideWindow
                """
                    |> TypeScript.Ipc.toTypes
                    |> Expect.equal (Ok [ TypeScript.Ipc.Msg "HideWindow" ])
        , test "another single type with no data" <|
            \_ ->
                """
                              module Ipc exposing (..)

                              import Json.Encode as Encode

                              type Msg
                                  = Quit
                            """
                    |> TypeScript.Ipc.toTypes
                    |> Expect.equal (Ok [ TypeScript.Ipc.Msg "Quit" ])
        , test "a single type with a String param" <|
            \_ ->
                """
                  module Ipc exposing (..)

                  type Msg
                      = Replicate String
                """
                    |> TypeScript.Ipc.toTypes
                    |> Expect.equal (Ok [ TypeScript.Ipc.MsgWithData "Replicate" TypeScript.Ipc.String ])
        , test "reports errors for unsupported types" <|
            \_ ->
                """
                                          module Ipc exposing (..)

                                          type Msg
                                              = Transport Banana
                                        """
                    |> TypeScript.Ipc.toTypes
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
                    |> TypeScript.Ipc.toTypes
                    |> Expect.equal
                        (Ok
                            [ TypeScript.Ipc.MsgWithData "Transport" TypeScript.Ipc.String
                            , TypeScript.Ipc.MsgWithData "SetPhasersTo" TypeScript.Ipc.String
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
                    |> TypeScript.Ipc.toTypes
                    |> Expect.equal
                        (Ok
                            [ TypeScript.Ipc.MsgWithData "Transport" TypeScript.Ipc.JsonEncodeValue
                            , TypeScript.Ipc.MsgWithData "UploadSchematic" TypeScript.Ipc.JsonEncodeValue
                            ]
                        )
        ]
