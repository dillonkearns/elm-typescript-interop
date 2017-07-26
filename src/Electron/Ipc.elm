module Electron.Ipc exposing (..)

import Ast
import Ast.Statement exposing (..)
import List.Extra


type ElmIpc
    = Msg String
    | MsgWithData String PayloadType


toElmIpc : Ast.Statement.Type -> Maybe ElmIpc
toElmIpc statement =
    case statement of
        TypeConstructor [ valueName ] [] ->
            Just (Msg valueName)

        _ ->
            Nothing


msgValues : List Ast.Statement.Statement -> Maybe (List Ast.Statement.Type)
msgValues ast =
    ast
        |> List.filterMap
            (\statement ->
                case statement of
                    TypeDeclaration (TypeConstructor [ "Msg" ] []) values ->
                        Just values

                    _ ->
                        Nothing
            )
        |> List.Extra.find (not << List.isEmpty)


type PayloadType
    = String


toTypes : String -> List ElmIpc
toTypes ipcFileAsString =
    case Ast.parse ipcFileAsString of
        Ok ( _, _, statements ) ->
            statements
                |> msgValues
                |> Maybe.withDefault []
                |> List.map toElmIpc
                |> List.filterMap identity

        err ->
            []
