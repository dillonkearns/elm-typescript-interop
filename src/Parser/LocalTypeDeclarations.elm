module Parser.LocalTypeDeclarations exposing (LocalTypeDeclarations, includes, localTypeDeclarations)

import Ast.Expression


type LocalTypeDeclarations
    = LocalTypeDeclarations (List String)


includes : String -> LocalTypeDeclarations -> Bool
includes typeName (LocalTypeDeclarations localTypeDeclarations) =
    localTypeDeclarations
        |> List.member typeName


localTypeDeclarations : List Ast.Expression.Statement -> LocalTypeDeclarations
localTypeDeclarations statements =
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
