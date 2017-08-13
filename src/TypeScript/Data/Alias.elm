module TypeScript.Data.Alias exposing (Alias(Alias))

import Ast.Statement


type Alias
    = Alias (List String) Ast.Statement.Type
