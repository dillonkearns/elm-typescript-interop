module TypeScript.Data.Program exposing (Main, Program(..))

import Ast.Expression
import ImportAlias exposing (ImportAlias)
import TypeScript.Data.Aliases as Aliases exposing (Aliases)
import TypeScript.Data.Port exposing (Port)


type alias Main =
    { moduleName : List String
    , flagsType : Maybe Ast.Expression.Type
    , filePath : String
    , importAliases : List ImportAlias
    , localTypeDeclarations : Aliases.LocalTypeDeclarations
    }


type Program
    = ElmProgram (List Main) Aliases (List Port)
