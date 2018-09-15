module TypeScript.Data.Port exposing (Direction(Inbound, Outbound), Port(Port))

import Ast.Expression
import Parser.Context exposing (Context)


type Direction
    = Inbound
    | Outbound


type Port
    = Port Context String Direction Ast.Expression.Type
