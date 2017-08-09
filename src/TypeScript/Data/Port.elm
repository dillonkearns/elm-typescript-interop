module TypeScript.Data.Port exposing (Port(Inbound, Outbound))

import Ast.Statement


type Port
    = Inbound String Ast.Statement.Type
    | Outbound String Ast.Statement.Type
