module TypeGeneratorTests exposing (suite, toTsTypeNoAlias)

import Ast.Expression exposing (Type(TypeConstructor, TypeRecord, TypeTuple))
import Expect
import Parser.Context exposing (Context)
import Parser.LocalTypeDeclarations as LocalTypeDeclarations
import Test exposing (Test, describe, test)
import TypeScript.Data.Aliases as Aliases
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
                    toTsType
                        ([ Aliases.alias stubContext [ "MyAlias" ] (TypeConstructor [ "Bool" ] []) ]
                            |> Aliases.aliasesFromList
                        )
                        (TypeConstructor [ "MyAlias" ]
                            []
                        )
                        |> expectOkValue "boolean"
            ]
        ]


expectOkValue : a -> Result error a -> Expect.Expectation
expectOkValue value =
    Expect.equal (Ok value)


toTsTypeNoAlias : Type -> Result String String
toTsTypeNoAlias =
    toTsType ([] |> Aliases.aliasesFromList)


toTsType : Aliases.Aliases -> Type -> Result String String
toTsType =
    TypeScript.TypeGenerator.toTsType stubContext


stubContext : Context
stubContext =
    { filePath = "stub/path"
    , statements = []
    , importAliases = []
    , moduleName = [ "Module", "Name" ]
    , localTypeDeclarations = [] |> LocalTypeDeclarations.fromStatements
    }
