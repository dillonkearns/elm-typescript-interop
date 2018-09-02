module TypeScript.Data.Program exposing (Main, Program(..))

import Ast.Expression
import TypeScript.Data.Aliases exposing (Aliases)
import TypeScript.Data.Port exposing (Port)


type alias Main =
    { moduleName : List String
    , flagsType : Maybe Ast.Expression.Type
    }


type Program
    = ElmProgram Main Aliases (List Port)
