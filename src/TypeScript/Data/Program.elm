module TypeScript.Data.Program exposing (..)

import Ast.Statement
import TypeScript.Data.Port exposing (Port)


type Program
    = WithFlags Ast.Statement.Type (List Port)
    | WithoutFlags (List Port)
