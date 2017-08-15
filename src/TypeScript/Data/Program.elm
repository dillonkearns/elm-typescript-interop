module TypeScript.Data.Program exposing (..)

import Ast.Statement
import TypeScript.Data.Aliases exposing (Aliases)
import TypeScript.Data.Port exposing (Port)


type alias Main =
    { moduleName : List String
    , flagsType : Maybe Ast.Statement.Type
    }


type Program
    = ElmProgram (Maybe Main) Aliases (List Port)
