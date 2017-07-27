module ElmSerializerTests exposing (suite)

import Electron.Generator.ElmSerializer
import Electron.Ipc
import Expect
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "elm serializer"
        [ test "case for a single msg with no parameter" <|
            \() ->
                Electron.Ipc.Msg "Engage"
                    |> Electron.Generator.ElmSerializer.generateCase
                    |> Expect.equal
                        ("""        Engage ->
            ( "Engage", Encode.null )"""
                            |> String.trimRight
                        )
        , test "case for another single msg with no parameter" <|
            \() ->
                Electron.Ipc.Msg "MakeItSo"
                    |> Electron.Generator.ElmSerializer.generateCase
                    |> Expect.equal
                        ("""        MakeItSo ->
            ( "MakeItSo", Encode.null )"""
                            |> String.trimRight
                        )
        , test "case for a single msg with a parameter" <|
            \() ->
                Electron.Ipc.MsgWithData "Transport" Electron.Ipc.String
                    |> Electron.Generator.ElmSerializer.generateCase
                    |> Expect.equal
                        ("""        Transport string ->
            ( "Transport", Encode.string string )"""
                            |> String.trimRight
                        )
        ]
