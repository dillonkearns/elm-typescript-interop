module TypeScript.Data.Port exposing (Direction(Inbound, Outbound), Port(Port))

import Ast.Expression
import ImportAlias exposing (ImportAlias)
import Parser.LocalTypeDeclarations as LocalTypeDeclarations exposing (LocalTypeDeclarations)


type Direction
    = Inbound
    | Outbound


type Port
    = Port String Direction Ast.Expression.Type (List ImportAlias) LocalTypeDeclarations (List String)
