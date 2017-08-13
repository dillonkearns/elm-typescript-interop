module TypeGeneratorTests exposing (..)

import Ast.Statement exposing (..)
import Expect
import Test exposing (Test, describe, test)
import TypeScript.TypeGenerator


suite : Test
suite =
    describe "type generator"
        [ describe "primitives types"
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
        , describe "compound types"
            [ test "Maybe" <|
                \() ->
                    Ast.Statement.TypeConstructor [ "Maybe" ] [ Ast.Statement.TypeConstructor [ "String" ] [] ]
                        |> TypeScript.TypeGenerator.toTsType
                        |> Expect.equal "string | null"
            , test "tuple" <|
                \() ->
                    TypeTuple [ TypeConstructor [ "Int" ] [], TypeConstructor [ "String" ] [], TypeConstructor [ "Bool" ] [] ]
                        |> TypeScript.TypeGenerator.toTsType
                        |> Expect.equal "[number, string, boolean]"
            , test "List" <|
                \() ->
                    TypeConstructor [ "List" ] [ TypeConstructor [ "Int" ] [] ]
                        |> TypeScript.TypeGenerator.toTsType
                        |> Expect.equal "number[]"
            , test "Array" <|
                \() ->
                    TypeConstructor [ "Array", "Array" ] [ TypeConstructor [ "String" ] [] ]
                        |> TypeScript.TypeGenerator.toTsType
                        |> Expect.equal "string[]"
            , test "unqualified Array" <|
                \() ->
                    TypeConstructor [ "Array" ] [ TypeConstructor [ "String" ] [] ]
                        |> TypeScript.TypeGenerator.toTsType
                        |> Expect.equal "string[]"
            , test "record literal" <|
                \() ->
                    TypeRecord [ ( "first", TypeConstructor [ "String" ] [] ), ( "last", TypeConstructor [ "String" ] [] ) ]
                        |> TypeScript.TypeGenerator.toTsType
                        |> Expect.equal "{ first: string; last: string }"
            ]
        ]
