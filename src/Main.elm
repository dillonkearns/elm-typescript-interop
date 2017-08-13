port module Main exposing (..)

import Json.Decode exposing (..)
import TypeScript.Data.Program
import TypeScript.Generator
import TypeScript.Parser


-- Need to import Json.Decode as a
-- workaround for https://github.com/elm-lang/elm-make/issues/134


workaround : Decoder String
workaround =
    Json.Decode.string


type alias Model =
    ()


type alias Flags =
    { elmModuleFileContents : List String }


output : List String -> Cmd msg
output elmModuleFileContents =
    elmModuleFileContents
        |> TypeScript.Parser.parse
        |> crashOrOutputString


crashOrOutputString : Result String TypeScript.Data.Program.Program -> Cmd msg
crashOrOutputString result =
    case result of
        Ok elmProgram ->
            let
                tsCode =
                    elmProgram
                        |> TypeScript.Generator.generate
            in
            generatedFiles tsCode

        Err errorMessage ->
            parsingError errorMessage


init : Flags -> ( Model, Cmd msg )
init flags =
    () ! [ output flags.elmModuleFileContents ]


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


port generatedFiles : String -> Cmd msg


port parsingError : String -> Cmd msg
