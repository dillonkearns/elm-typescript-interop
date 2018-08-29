module TypeGeneratorTests exposing (suite, toTsTypeNoAlias)

import Ast.Statement exposing (Type(TypeConstructor, TypeRecord, TypeTuple))
import Dict
import Expect
import Test exposing (Test, describe, test)
import TypeScript.TypeGenerator


suite : Test
suite =
    describe "type generator"
        [ describe "primitives types"
            [ test "String" <|
                \() ->
                    TypeConstructor [ "String" ] []
                        |> toTsTypeNoAlias
                        |> Expect.equal "string"
            , test "Float" <|
                \() ->
                    TypeConstructor [ "Float" ] []
                        |> toTsTypeNoAlias
                        |> Expect.equal "number"
            , test "Int" <|
                \() ->
                    TypeConstructor [ "Int" ] []
                        |> toTsTypeNoAlias
                        |> Expect.equal "number"
            , test "Bool" <|
                \() ->
                    TypeConstructor [ "Bool" ] []
                        |> toTsTypeNoAlias
                        |> Expect.equal "boolean"
            ]
        , describe "compound types"
            [ test "Maybe" <|
                \() ->
                    TypeConstructor [ "Maybe" ] [ TypeConstructor [ "String" ] [] ]
                        |> toTsTypeNoAlias
                        |> Expect.equal "string | null"
            , test "tuple" <|
                \() ->
                    TypeTuple [ TypeConstructor [ "Int" ] [], TypeConstructor [ "String" ] [], TypeConstructor [ "Bool" ] [] ]
                        |> toTsTypeNoAlias
                        |> Expect.equal "[number, string, boolean]"
            , test "unit type" <|
                \() ->
                    TypeTuple []
                        |> toTsTypeNoAlias
                        |> Expect.equal "null"
            , test "List" <|
                \() ->
                    TypeConstructor [ "List" ] [ TypeConstructor [ "Int" ] [] ]
                        |> toTsTypeNoAlias
                        |> Expect.equal "number[]"
            , test "Array" <|
                \() ->
                    TypeConstructor [ "Array", "Array" ] [ TypeConstructor [ "String" ] [] ]
                        |> toTsTypeNoAlias
                        |> Expect.equal "string[]"
            , test "unqualified Array" <|
                \() ->
                    TypeConstructor [ "Array" ] [ TypeConstructor [ "String" ] [] ]
                        |> toTsTypeNoAlias
                        |> Expect.equal "string[]"
            , test "record literal" <|
                \() ->
                    TypeRecord [ ( "first", TypeConstructor [ "String" ] [] ), ( "last", TypeConstructor [ "String" ] [] ) ]
                        |> toTsTypeNoAlias
                        |> Expect.equal "{ first: string; last: string }"
            , test "Json.Decode.Value" <|
                \() ->
                    TypeConstructor [ "Json", "Decode", "Value" ] []
                        |> toTsTypeNoAlias
                        |> Expect.equal "any"
            , test "Json.Encode.Value" <|
                \() ->
                    TypeConstructor [ "Json", "Encode", "Value" ] []
                        |> toTsTypeNoAlias
                        |> Expect.equal "any"
            , test "aliased Encode.Value" <|
                \() ->
                    TypeConstructor [ "Encode", "Value" ] []
                        |> toTsTypeNoAlias
                        |> Expect.equal "any"
            ]
        , describe "alias lookup"
            [ test "single string alias" <|
                \() ->
                    TypeConstructor [ "MyAlias" ]
                        []
                        |> TypeScript.TypeGenerator.toTsType (Dict.fromList [ ( [ "MyAlias" ], TypeConstructor [ "Bool" ] [] ) ])
                        |> Expect.equal "boolean"
            ]
        ]


toTsTypeNoAlias : Type -> String
toTsTypeNoAlias =
    TypeScript.TypeGenerator.toTsType Dict.empty
