module AliasesTests exposing (suite)

import Ast.Expression
import Expect
import Test exposing (Test, describe, only, test)
import TypeScript.Data.Aliases as Aliases


suite : Test
suite =
    test "unqualified alias is the same as an import alias" <|
        \() ->
            Aliases.alias [ "Aliases", "Alias" ] [] typeAliasAst
                |> Expect.equal
                    (Aliases.alias [ "MyImportAlias", "Alias" ]
                        [ { unqualifiedModuleName = [ "Aliases" ]
                          , aliasName = "MyImportAlias"
                          , exposed = []
                          }
                        ]
                        typeAliasAst
                    )


typeAliasAst : Ast.Expression.Type
typeAliasAst =
    Ast.Expression.TypeConstructor [ "Int" ] []
