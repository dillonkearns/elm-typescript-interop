module TypeScript.Data.Aliases exposing (Aliases)

import Ast.Statement
import Dict exposing (Dict)


type alias Aliases =
    Dict (List String) Ast.Statement.Type
