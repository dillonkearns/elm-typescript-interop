module GeneratorTests exposing (..)

import Ast.Statement
import Dict
import Expect
import Test exposing (Test, describe, test)
import TypeScript.Data.Port as Port
import TypeScript.Generator


suite : Test
suite =
    describe "generator"
        [ describe "port"
            [ test "outbound port" <|
                \() ->
                    Port.Port "hello" Port.Outbound (Ast.Statement.TypeConstructor [ "String" ] [])
                        |> TypeScript.Generator.generatePort Dict.empty
                        |> Expect.equal
                            """    hello: {
      subscribe(callback: (data: string) => void): void
    }"""
            , test "inbound port" <|
                \() ->
                    Port.Port "reply" Port.Inbound (Ast.Statement.TypeConstructor [ "Int" ] [])
                        |> TypeScript.Generator.generatePort Dict.empty
                        |> Expect.equal
                            """    reply: {
      send(data: number): void
    }"""
            ]
        ]
