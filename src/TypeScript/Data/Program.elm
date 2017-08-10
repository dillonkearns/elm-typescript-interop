module TypeScript.Data.Program exposing (..)

import Ast.Statement
import TypeScript.Data.Port exposing (Port)


type Program
    = ElmProgram (Maybe Ast.Statement.Type) (List Port)
