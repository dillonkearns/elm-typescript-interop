module TypeScript.Data.Program exposing (..)

import Ast.Statement
import TypeScript.Data.Alias exposing (Alias)
import TypeScript.Data.Port exposing (Port)


type Program
    = ElmProgram (Maybe Ast.Statement.Type) (List Alias) (List Port)
