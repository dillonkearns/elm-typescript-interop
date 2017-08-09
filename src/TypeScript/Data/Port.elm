module TypeScript.Data.Port exposing (Kind(Inbound, Outbound), Port(Port))

import Ast.Statement


type Kind
    = Inbound
    | Outbound


type Port
    = Port String Kind Ast.Statement.Type
