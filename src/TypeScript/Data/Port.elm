module TypeScript.Data.Port exposing (Direction(Inbound, Outbound), Port(Port))

import Ast.Expression
import ImportAlias exposing (ImportAlias)
import TypeScript.Data.Aliases as Aliases


type Direction
    = Inbound
    | Outbound


type Port
    = Port String Direction Ast.Expression.Type (List ImportAlias) Aliases.LocalTypeDeclarations
