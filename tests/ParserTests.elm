module ParserTests exposing (..)

import Expect exposing (Expectation)
import Test exposing (..)
import TypeScript.Data.Port
import TypeScript.Data.Program
import TypeScript.Parser


portNameAndDirection : TypeScript.Data.Port.Port -> ( String, TypeScript.Data.Port.Direction )
portNameAndDirection portValue =
    case portValue of
        TypeScript.Data.Port.Port name kind _ ->
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
        , test "program with an outbound port" <|
            \_ ->
                """
                  module Main exposing (main)

                  thereAreNoPorts = True
                  port greet : String -> Cmd msg
                """
                    |> TypeScript.Parser.parse
                    |> (\parsed ->
                            case parsed of
                                Ok (TypeScript.Data.Program.WithoutFlags ports) ->
                                    List.map portNameAndDirection ports
                                        |> Expect.equal [ ( "greet", TypeScript.Data.Port.Outbound ) ]

                                actual ->
                                    Expect.fail "Expeted program without flags"
                       )
        ]
