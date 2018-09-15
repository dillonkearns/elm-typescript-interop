module TypeScript.Data.Program exposing (Main, Program(..))

import Ast.Expression
import Parser.Context exposing (Context)
import TypeScript.Data.Aliases as Aliases exposing (Aliases)
import TypeScript.Data.Port exposing (Port)


type alias Main =
    { flagsType : Maybe Ast.Expression.Type
    , context : Context
    }


type Program
    = ElmProgram (List Main) Aliases (List Port)
