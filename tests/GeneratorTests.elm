module GeneratorTests exposing (..)

import Ast.Statement
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
                        |> TypeScript.Generator.generatePort
                        |> Expect.equal
                            """    hello: {
      subscribe(callback: (data: string) => void): void
    }"""
            , test "inbound port" <|
                \() ->
                    Port.Port "reply" Port.Inbound (Ast.Statement.TypeConstructor [ "Int" ] [])
                        |> TypeScript.Generator.generatePort
                        |> Expect.equal
                            """    reply: {
      send(data: number): void
    }"""
            ]
        , describe "type"
            [ test "String" <|
                \() ->
                    Ast.Statement.TypeConstructor [ "String" ] []
                        |> TypeScript.Generator.toTypescriptType
                        |> Expect.equal "string"
            , test "Float" <|
                \() ->
                    Ast.Statement.TypeConstructor [ "Float" ] []
                        |> TypeScript.Generator.toTypescriptType
                        |> Expect.equal "number"
            , test "Int" <|
                \() ->
                    Ast.Statement.TypeConstructor [ "Int" ] []
                        |> TypeScript.Generator.toTypescriptType
                        |> Expect.equal "number"
            , test "Bool" <|
                \() ->
                    Ast.Statement.TypeConstructor [ "Bool" ] []
                        |> TypeScript.Generator.toTypescriptType
                        |> Expect.equal "boolean"
            ]
        ]
