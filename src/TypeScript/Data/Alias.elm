module TypeScript.Data.Alias exposing (Alias(Alias), Direction(Inbound, Outbound))

import Ast.Statement


type Direction
    = Inbound
    | Outbound


type Alias
    = Alias String Ast.Statement.Type
