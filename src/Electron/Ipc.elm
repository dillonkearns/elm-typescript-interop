module Electron.Ipc exposing (..)

import Ast
import Ast.Statement exposing (..)
import List.Extra


type ElmIpc
    = Msg String
    | MsgWithData String PayloadType


toElmIpc : Ast.Statement.Type -> Result String ElmIpc
toElmIpc statement =
    case statement of
        TypeConstructor [ valueName ] [] ->
            Result.Ok (Msg valueName)

        TypeConstructor [ ipcMsgName ] [ TypeConstructor parameterType [] ] ->
            case parameterType of
                [ "String" ] ->
                    MsgWithData ipcMsgName String |> Result.Ok

                [ "Encode", "Value" ] ->
                    MsgWithData ipcMsgName JsonEncodeValue |> Result.Ok

                unsupportedType ->
                    "Unsupported parameter type for " ++ ipcMsgName ++ " constructor: " ++ String.join "." unsupportedType |> Result.Err

        unhandledConstructor ->
            "Unhandled type constructor: " ++ toString unhandledConstructor |> Result.Err


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
    | JsonEncodeValue


compositeResult : List (Result String ElmIpc) -> Result String (List ElmIpc)
compositeResult list =
    if List.all isOk list then
        list
            |> List.filterMap Result.toMaybe
            |> Ok
    else
        list
            |> List.filterMap errorOrNothing
            |> String.join "\n"
            |> Err


isOk : Result err ok -> Bool
isOk result =
    case result of
        Ok _ ->
            True

        Err _ ->
            False


errorOrNothing : Result String ElmIpc -> Maybe String
errorOrNothing result =
    case result of
        Ok _ ->
            Nothing

        Err errorString ->
            Just errorString


toTypes : String -> Result String (List ElmIpc)
toTypes ipcFileAsString =
    case Ast.parse ipcFileAsString of
        Ok ( _, _, statements ) ->
            statements
                |> msgValues
                |> Maybe.withDefault []
                |> List.map toElmIpc
                |> compositeResult

        err ->
            err |> toString |> Err
