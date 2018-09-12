module TypeGeneratorTests exposing (suite, toTsTypeNoAlias)

import Ast.Expression exposing (Type(TypeConstructor, TypeRecord, TypeTuple))
import Dict
import Expect
import Test exposing (Test, describe, test)
import TypeScript.Data.Aliases
import TypeScript.TypeGenerator


suite : Test
suite =
    describe "type generator"
        [ describe "primitives types"
            [ test "String" <|
                \() ->
                    TypeConstructor [ "String" ] []
                        |> toTsTypeNoAlias
                        |> expectOkValue "string"
            , test "Float" <|
                \() ->
                    TypeConstructor [ "Float" ] []
                        |> toTsTypeNoAlias
                        |> expectOkValue "number"
            , test "Int" <|
                \() ->
                    TypeConstructor [ "Int" ] []
                        |> toTsTypeNoAlias
                        |> expectOkValue "number"
            , test "Bool" <|
                \() ->
                    TypeConstructor [ "Bool" ] []
                        |> toTsTypeNoAlias
                        |> expectOkValue "boolean"
            ]
        , describe "compound types"
            [ test "Maybe" <|
                \() ->
                    TypeConstructor [ "Maybe" ] [ TypeConstructor [ "String" ] [] ]
                        |> toTsTypeNoAlias
                        |> expectOkValue "string | null"
            , test "tuple" <|
                \() ->
                    TypeTuple [ TypeConstructor [ "Int" ] [], TypeConstructor [ "String" ] [], TypeConstructor [ "Bool" ] [] ]
                        |> toTsTypeNoAlias
                        |> expectOkValue "[number, string, boolean]"
            , test "unit type" <|
                \() ->
                    TypeTuple []
                        |> toTsTypeNoAlias
                        |> expectOkValue "null"
            , test "List" <|
                \() ->
                    TypeConstructor [ "List" ] [ TypeConstructor [ "Int" ] [] ]
                        |> toTsTypeNoAlias
                        |> expectOkValue "number[]"
            , test "Array" <|
                \() ->
                    TypeConstructor [ "Array", "Array" ] [ TypeConstructor [ "String" ] [] ]
                        |> toTsTypeNoAlias
                        |> expectOkValue "string[]"
            , test "unqualified Array" <|
                \() ->
                    TypeConstructor [ "Array" ] [ TypeConstructor [ "String" ] [] ]
                        |> toTsTypeNoAlias
                        |> expectOkValue "string[]"
            , test "record literal" <|
                \() ->
                    TypeRecord [ ( "first", TypeConstructor [ "String" ] [] ), ( "last", TypeConstructor [ "String" ] [] ) ]
                        |> toTsTypeNoAlias
                        |> expectOkValue "{ first: string; last: string }"
            , test "Json.Decode.Value" <|
                \() ->
                    TypeConstructor [ "Json", "Decode", "Value" ] []
                        |> toTsTypeNoAlias
                        |> expectOkValue "unknown"
            , test "Json.Encode.Value" <|
                \() ->
                    TypeConstructor [ "Json", "Encode", "Value" ] []
                        |> toTsTypeNoAlias
                        |> expectOkValue "unknown"
            , test "aliased Encode.Value" <|
                \() ->
                    TypeConstructor [ "Encode", "Value" ] []
                        |> toTsTypeNoAlias
                        |> Expect.equal (Ok "unknown")
            ]
        , describe "alias lookup"
            [ test "single string alias" <|
                \() ->
                    TypeConstructor [ "MyAlias" ]
                        []
                        |> TypeScript.TypeGenerator.toTsType
                            (Dict.fromList [ ( [ "MyAlias" ], TypeConstructor [ "Bool" ] [] ) ]
                                |> TypeScript.Data.Aliases.aliases
                            )
                        |> expectOkValue "boolean"
            ]
        ]


expectOkValue : a -> Result error a -> Expect.Expectation
expectOkValue value =
    Expect.equal (Ok value)


toTsTypeNoAlias : Type -> Result String String
toTsTypeNoAlias =
    TypeScript.TypeGenerator.toTsType (TypeScript.Data.Aliases.aliases Dict.empty)
