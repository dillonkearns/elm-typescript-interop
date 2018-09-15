module Parser.Context exposing (Context)

import Ast.Expression
import ImportAlias exposing (ImportAlias)
import Parser.LocalTypeDeclarations as LocalTypeDeclarations exposing (LocalTypeDeclarations)


type alias Context =
    { filePath : String
    , statements : List Ast.Expression.Statement
    , importAliases : List ImportAlias
    , localTypeDeclarations : LocalTypeDeclarations
    , moduleName : List String
    }
