module TypeScript.Parser exposing (..)

import Ast
import Ast.Statement exposing (..)
import TypeScript.Data.Port as Port exposing (Port(Port))
import TypeScript.Data.Program


extractPort : Ast.Statement.Statement -> Maybe Port
extractPort statement =
    case statement of
        PortTypeDeclaration outboundPortName (TypeApplication outboundPortType (TypeConstructor [ "Cmd" ] [ TypeVariable _ ])) ->
            Port outboundPortName Port.Outbound outboundPortType |> Just

        PortTypeDeclaration inboundPortName (TypeApplication (TypeApplication inboundPortType (TypeVariable _)) (TypeConstructor [ "Sub" ] [ TypeVariable _ ])) ->
            Port inboundPortName Port.Inbound inboundPortType |> Just

        _ ->
            Nothing


toProgram : List Ast.Statement.Statement -> TypeScript.Data.Program.Program
toProgram statements =
    let
        ports =
            List.filterMap extractPort statements

        flagsType =
            statements
                |> List.filterMap programFlagType
                |> List.head
    in
    TypeScript.Data.Program.ElmProgram flagsType ports


programFlagType : Ast.Statement.Statement -> Maybe Ast.Statement.Type
programFlagType statement =
    case statement of
        FunctionTypeDeclaration "main" (TypeConstructor [ "Program" ] [ flagsType, TypeConstructor [ modelType ] [], TypeConstructor [ msgType ] [] ]) ->
            case flagsType of
                TypeConstructor [ "Never" ] [] ->
                    Nothing

                _ ->
                    Just flagsType

        _ ->
            Nothing


parse : String -> Result String TypeScript.Data.Program.Program
parse ipcFileAsString =
    case Ast.parse ipcFileAsString of
        Ok ( _, _, statements ) ->
            statements
                |> toProgram
                |> Ok

        err ->
            err |> toString |> Err
