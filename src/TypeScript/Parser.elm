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
