module IpcTests exposing (..)

import Electron.Ipc
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
                    |> Electron.Ipc.toTypes
                    |> Expect.equal (Ok [ Electron.Ipc.Msg "HideWindow" ])
        , test "another single type with no data" <|
            \_ ->
                """
                              module Ipc exposing (..)

                              import Json.Encode as Encode

                              type Msg
                                  = Quit
                            """
                    |> Electron.Ipc.toTypes
                    |> Expect.equal (Ok [ Electron.Ipc.Msg "Quit" ])
        , test "a single type with a String param" <|
            \_ ->
                """
                  module Ipc exposing (..)

                  type Msg
                      = Replicate String
                """
                    |> Electron.Ipc.toTypes
                    |> Expect.equal (Ok [ Electron.Ipc.MsgWithData "Replicate" Electron.Ipc.String ])
        , test "reports errors for unsupported types" <|
            \_ ->
                """
                                          module Ipc exposing (..)

                                          type Msg
                                              = Transport Banana
                                        """
                    |> Electron.Ipc.toTypes
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
                    |> Electron.Ipc.toTypes
                    |> Expect.equal
                        (Ok
                            [ Electron.Ipc.MsgWithData "Transport" Electron.Ipc.String
                            , Electron.Ipc.MsgWithData "SetPhasersTo" Electron.Ipc.String
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
                    |> Electron.Ipc.toTypes
                    |> Expect.equal
                        (Ok
                            [ Electron.Ipc.MsgWithData "Transport" Electron.Ipc.JsonEncodeValue
                            , Electron.Ipc.MsgWithData "UploadSchematic" Electron.Ipc.JsonEncodeValue
                            ]
                        )
        ]
