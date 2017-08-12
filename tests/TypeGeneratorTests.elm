module TypeGeneratorTests exposing (..)

import Ast.Statement
import Expect
import Test exposing (Test, describe, test)
import TypeScript.TypeGenerator


suite : Test
suite =
    describe "type generator"
        [ test "String" <|
            \() ->
                Ast.Statement.TypeConstructor [ "String" ] []
                    |> TypeScript.TypeGenerator.toTsType
                    |> Expect.equal "string"
        , test "Float" <|
            \() ->
                Ast.Statement.TypeConstructor [ "Float" ] []
                    |> TypeScript.TypeGenerator.toTsType
                    |> Expect.equal "number"
        , test "Int" <|
            \() ->
                Ast.Statement.TypeConstructor [ "Int" ] []
                    |> TypeScript.TypeGenerator.toTsType
                    |> Expect.equal "number"
        , test "Bool" <|
            \() ->
                Ast.Statement.TypeConstructor [ "Bool" ] []
                    |> TypeScript.TypeGenerator.toTsType
                    |> Expect.equal "boolean"
        ]
