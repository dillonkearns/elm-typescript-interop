module Parser.LocalTypeDeclarations exposing (LocalTypeDeclarations, fromStatements, includes)

import Ast.Expression


type LocalTypeDeclarations
    = LocalTypeDeclarations (List String)


includes : String -> LocalTypeDeclarations -> Bool
includes typeName (LocalTypeDeclarations fromStatements) =
    fromStatements
        |> List.member typeName


fromStatements : List Ast.Expression.Statement -> LocalTypeDeclarations
fromStatements statements =
    List.filterMap typeDeclaration statements
        |> LocalTypeDeclarations


typeDeclaration : Ast.Expression.Statement -> Maybe String
typeDeclaration statement =
    case statement of
        Ast.Expression.TypeDeclaration (Ast.Expression.TypeConstructor [ typeName ] _) _ ->
            Just typeName

        Ast.Expression.TypeAliasDeclaration (Ast.Expression.TypeConstructor [ typeName ] _) _ ->
            Just typeName

        _ ->
            Nothing
