module ParserTests exposing (..)

import Expect exposing (Expectation)
import Test exposing (..)
import TypeScript.Data.Port
import TypeScript.Data.Program
import TypeScript.Parser


portNameAndDirection : TypeScript.Data.Port.Port -> ( String, TypeScript.Data.Port.Direction )
portNameAndDirection (TypeScript.Data.Port.Port name kind _) =
    ( name, kind )


suite : Test
suite =
    describe "parser"
        [ test "program with no ports" <|
            \_ ->
                """
                  module Main exposing (main)

                  thereAreNoPorts = True
                """
                    |> TypeScript.Parser.parse
                    |> Expect.equal (Ok (TypeScript.Data.Program.WithoutFlags []))
        , test "program with an outbound ports" <|
            \_ ->
                """
                  module Main exposing (main)

                  port showSuccessDialog : String -> Cmd msg

                  port showWarningDialog : String -> Cmd msg
                """
                    |> TypeScript.Parser.parse
                    |> (\parsed ->
                            case parsed of
                                Ok (TypeScript.Data.Program.WithoutFlags ports) ->
                                    List.map portNameAndDirection ports
                                        |> Expect.equal
                                            [ ( "showSuccessDialog", TypeScript.Data.Port.Outbound )
                                            , ( "showWarningDialog", TypeScript.Data.Port.Outbound )
                                            ]

                                Err err ->
                                    Expect.fail ("Expected success, got" ++ toString parsed)

                                actual ->
                                    Expect.fail "Expeted program without flags"
                       )
        ]
