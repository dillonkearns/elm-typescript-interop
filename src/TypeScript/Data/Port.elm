module TypeScript.Data.Port exposing (Direction(Inbound, Outbound), Port(Port))

import Ast.Expression


type Direction
    = Inbound
    | Outbound


type Port
    = Port String Direction Ast.Expression.Type
