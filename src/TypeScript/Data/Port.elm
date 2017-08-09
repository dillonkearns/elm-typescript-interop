module TypeScript.Data.Port exposing (Port(Inbound, Outbound))

import Ast.Statement


type Port
    = Inbound Ast.Statement.Type
    | Outbound Ast.Statement.Type
