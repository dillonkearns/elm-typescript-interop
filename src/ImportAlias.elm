module ImportAlias exposing (ImportAlias, fromExpression, typeDeclaration)

import Ast.Expression


type Exposing
    = ExposeType String
    | ModuleTypePrecedence String


type alias ImportAlias =
    { unqualifiedModuleName : List String
    , aliasName : String
    , exposed : List String

    -- , exposed : List Exposing
    }


exposedFromModule : Ast.Expression.Statement -> List Exposing
exposedFromModule statement =
    []


typeDeclaration : Ast.Expression.Statement -> Maybe String
typeDeclaration statement =
    case statement of
        Ast.Expression.TypeDeclaration (Ast.Expression.TypeConstructor [ typeName ] _) _ ->
            Just typeName

        Ast.Expression.TypeAliasDeclaration (Ast.Expression.TypeConstructor [ typeName ] _) _ ->
            Just typeName

        _ ->
            Nothing


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
