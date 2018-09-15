module AliasesTests exposing (suite)

import Ast.Expression
import Expect
import Parser.Context exposing (Context)
import Parser.LocalTypeDeclarations as LocalTypeDeclarations
import Test exposing (Test, describe, only, test)
import TypeScript.Data.Aliases as Aliases


suite : Test
suite =
    test "unqualified alias is the same as an import alias" <|
        \() ->
            Aliases.alias stubContext [ "Aliases", "Alias" ] typeAliasAst
                |> Expect.equal
                    (Aliases.alias stubContext
                        [ "MyImportAlias", "Alias" ]
                        typeAliasAst
                    )


typeAliasAst : Ast.Expression.Type
typeAliasAst =
    Ast.Expression.TypeConstructor [ "Int" ] []


stubContext : Context
stubContext =
    { filePath = "stub/path"
    , statements = []
    , importAliases =
        [ { unqualifiedModuleName = [ "Aliases" ]
          , aliasName = "MyImportAlias"
          , exposed = []
          }
        ]
    , moduleName = [ "Module", "Name" ]
    , localTypeDeclarations = [] |> LocalTypeDeclarations.fromStatements
    }
