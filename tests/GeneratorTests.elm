module GeneratorTests exposing (suite)

import Ast.Expression
import Dict
import Expect
import Test exposing (Test, describe, test)
import TypeScript.Data.Aliases
import TypeScript.Data.Port as Port
import TypeScript.Generator


suite : Test
suite =
    describe "generator"
        [ describe "port"
            [ test "outbound port" <|
                \() ->
                    Port.Port "hello" Port.Outbound (Ast.Expression.TypeConstructor [ "String" ] [])
                        |> TypeScript.Generator.generatePort (Dict.empty |> TypeScript.Data.Aliases.aliases)
                        |> Expect.equal
                            (Ok
                                """    hello: {
      subscribe(callback: (data: string) => void): void
    }"""
                            )
            , test "inbound port" <|
                \() ->
                    Port.Port "reply" Port.Inbound (Ast.Expression.TypeConstructor [ "Int" ] [])
                        |> TypeScript.Generator.generatePort (Dict.empty |> TypeScript.Data.Aliases.aliases)
                        |> Expect.equal
                            (Ok
                                """    reply: {
      send(data: number): void
    }"""
                            )
            ]
        ]
