port module Main exposing (..)

import Electron.Generator.Ts
import Electron.Ipc
import Json.Decode exposing (..)


type alias Model =
    ()


type alias Flags =
    { elmIpcFileContents : String }


output : String -> String
output elmIpcFileContents =
    elmIpcFileContents
        |> Electron.Ipc.toTypes
        |> Electron.Generator.Ts.generate


init : Flags -> ( Model, Cmd msg )
init flags =
    () ! [ generatedTypescript (output flags.elmIpcFileContents) ]


update : msg -> Model -> ( Model, Cmd msg )
update msg model =
    model ! []


main : Program Flags Model msg
main =
    Platform.programWithFlags
        { init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        }


port generatedTypescript : String -> Cmd msg
