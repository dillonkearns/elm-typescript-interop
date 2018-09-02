module TypeScript.Data.Aliases exposing (Aliases, AliasesNew)

import Ast.Expression
import Dict exposing (Dict)


type alias Aliases =
    Dict (List String) Ast.Expression.Type


type alias AliasesNew =
    List ( List String, Ast.Expression.Type )
