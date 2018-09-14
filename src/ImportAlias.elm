module ImportAlias exposing (ImportAlias, fromExpression)

import Ast.Expression


type alias ImportAlias =
    { unqualifiedModuleName : List String
    , aliasName : String
    , exposed : List String
    }


fromExpression : Ast.Expression.Statement -> Maybe ImportAlias
fromExpression expression =
    case expression of
        Ast.Expression.ImportStatement moduleName maybeAlias maybeExposed ->
            maybeAlias
                |> Maybe.map
                    (\aliasName ->
                        { unqualifiedModuleName = moduleName
                        , aliasName = aliasName
                        , exposed = []
                        }
                    )

        _ ->
            Nothing
