module TypeScript.Data.Port exposing (Direction(Inbound, Outbound), Port(Port))

import Ast.Statement


type Direction
    = Inbound
    | Outbound


type Port
    = Port String Direction Ast.Statement.Type
