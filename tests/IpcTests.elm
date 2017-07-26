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
                    |> Expect.equal [ Electron.Ipc.Msg "HideWindow" ]
        , test "another single type with no data" <|
            \_ ->
                """
                  module Ipc exposing (..)

                  import Json.Encode as Encode

                  type Msg
                      = Quit
                """
                    |> Electron.Ipc.toTypes
                    |> Expect.equal [ Electron.Ipc.Msg "Quit" ]
        ]
