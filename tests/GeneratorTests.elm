module GeneratorTests exposing (..)

import Ast.Statement
import Expect
import Test exposing (Test, describe, test)
import TypeScript.Data.Port as Port
import TypeScript.Generator


suite : Test
suite =
    describe "generator"
        [ test "outbound port" <|
            \() ->
                Port.Port "hello" Port.Outbound (Ast.Statement.TypeConstructor [ "String" ] [])
                    |> TypeScript.Generator.generatePort
                    |> Expect.equal
                        """    hello: {
      subscribe(callback: (data: string) => void): void
    }"""
        ]
