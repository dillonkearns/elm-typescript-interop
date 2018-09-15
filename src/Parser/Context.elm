module Parser.Context exposing (Context)

import Ast.Expression
import ImportAlias exposing (ImportAlias)
import TypeScript.Data.Aliases as Aliases exposing (Aliases)


type alias Context =
    { path : String
    , statements : List Ast.Expression.Statement
    , importAliases : List ImportAlias
    , localTypeDeclarations : Aliases.LocalTypeDeclarations
    , moduleName : List String
    }
