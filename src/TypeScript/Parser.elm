module TypeScript.Parser exposing (..)

import Ast
import Ast.Statement exposing (..)
import List.Extra
import TypeScript.Data.Port
import TypeScript.Data.Program


extractPort : Ast.Statement.Statement -> Maybe TypeScript.Data.Port.Port
extractPort statement =
    case statement of
        PortTypeDeclaration outboundPortName (TypeApplication outboundPortType (TypeConstructor [ "Cmd" ] [ TypeVariable _ ])) ->
            TypeScript.Data.Port.Outbound outboundPortName outboundPortType |> Just

        _ ->
            Nothing


toProgram : List Ast.Statement.Statement -> TypeScript.Data.Program.Program
toProgram statements =
    let
        ports =
            List.filterMap extractPort statements
    in
    TypeScript.Data.Program.WithoutFlags ports


parse : String -> Result String TypeScript.Data.Program.Program
parse ipcFileAsString =
    case Ast.parse ipcFileAsString of
        Ok ( _, _, statements ) ->
            statements
                |> toProgram
                |> Ok

        err ->
            err |> toString |> Err


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

        TypeConstructor [ ipcMsgName ] [ TypeRecord recordDetails ] ->
            "Record constructor parameters are not yet supported: " ++ ipcMsgName ++ " constructor: " ++ toString recordDetails |> Result.Err

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
