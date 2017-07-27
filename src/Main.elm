port module Main exposing (..)

import Electron.Generator.ElmSerializer
import Electron.Generator.Ts
import Electron.Ipc exposing (ElmIpc)
import Json.Decode exposing (..)


-- Need to import Json.Decode as a
-- workaround for https://github.com/elm-lang/elm-make/issues/134


workaround : Decoder String
workaround =
    Json.Decode.string


type alias Model =
    ()


type alias Flags =
    { elmIpcFileContents : String }


output : String -> Cmd msg
output elmIpcFileContents =
    elmIpcFileContents
        |> Electron.Ipc.toTypes
        |> crashOrOutputString


crashOrOutputString : Result String (List ElmIpc) -> Cmd msg
crashOrOutputString result =
    case result of
        Ok elmIpcList ->
            let
                tsCode =
                    elmIpcList
                        |> Electron.Generator.Ts.generate

                elmCode =
                    elmIpcList
                        |> Electron.Generator.ElmSerializer.generate
            in
            generatedFiles ( tsCode, elmCode )

        Err errorMessage ->
            parsingError errorMessage


init : Flags -> ( Model, Cmd msg )
init flags =
    () ! [ output flags.elmIpcFileContents ]


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


port generatedFiles : ( String, String ) -> Cmd msg


port parsingError : String -> Cmd msg
