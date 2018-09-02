module TypeScript.Data.Aliases exposing (Aliases)

import Ast.Expression
import Dict exposing (Dict)


type alias Aliases =
    Dict (List String) Ast.Expression.Type
