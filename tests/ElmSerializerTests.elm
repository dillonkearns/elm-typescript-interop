module ElmSerializerTests exposing (suite)

import Expect
import Test exposing (Test, describe, test)
import TypeScript.Generator.ElmSerializer
import TypeScript.Ipc


suite : Test
suite =
    describe "elm serializer"
        [ test "case for a single msg with no parameter" <|
            \() ->
                TypeScript.Ipc.Msg "Engage"
                    |> TypeScript.Generator.ElmSerializer.generateCase
                    |> Expect.equal
                        ("""        Engage ->
            ( "Engage", Encode.null )"""
                            |> String.trimRight
                        )
        , test "case for another single msg with no parameter" <|
            \() ->
                TypeScript.Ipc.Msg "MakeItSo"
                    |> TypeScript.Generator.ElmSerializer.generateCase
                    |> Expect.equal
                        ("""        MakeItSo ->
            ( "MakeItSo", Encode.null )"""
                            |> String.trimRight
                        )
        , test "case for a single msg with a parameter" <|
            \() ->
                TypeScript.Ipc.MsgWithData "Transport" TypeScript.Ipc.String
                    |> TypeScript.Generator.ElmSerializer.generateCase
                    |> Expect.equal
                        ("""        Transport string ->
            ( "Transport", Encode.string string )"""
                            |> String.trimRight
                        )
        , test "case for a single msg with an encode value parameter" <|
            \() ->
                TypeScript.Ipc.MsgWithData "SetPhasersTo" TypeScript.Ipc.JsonEncodeValue
                    |> TypeScript.Generator.ElmSerializer.generateCase
                    |> Expect.equal
                        ("""        SetPhasersTo value ->
            ( "SetPhasersTo", value )"""
                            |> String.trimRight
                        )
        ]
