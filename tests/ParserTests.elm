module ParserTests exposing (..)

import Ast.Statement
import Expect exposing (Expectation)
import Test exposing (..)
import TypeScript.Data.Port
import TypeScript.Data.Program
import TypeScript.Parser


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
                                Ok (TypeScript.Data.Program.WithoutFlags [ singlePort ]) ->
                                    case singlePort of
                                        TypeScript.Data.Port.Outbound _ ->
                                            Expect.pass

                                        _ ->
                                            Expect.fail "Expected outbound port, got inbound"

                                actual ->
                                    Expect.fail ("Expeted single port without flags, got " ++ toString actual)
                       )
        ]
