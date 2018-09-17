port module Main exposing (Flags, Model, crashOrOutputString, generatedFiles, init, main, output, parsingError, update, workaround)

import ElmProjectConfig exposing (ElmVersion)
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
    { elmVersion : ElmProjectConfig.ElmVersion }


output : ElmProjectConfig.ElmVersion -> List SourceFile -> Cmd msg
output elmVersion elmModuleFileContents =
    elmModuleFileContents
        |> TypeScript.Parser.parse
        |> crashOrOutputString elmVersion


crashOrOutputString : ElmVersion -> Result String TypeScript.Data.Program.Program -> Cmd msg
crashOrOutputString elmVersion result =
    case result of
        Ok elmProgram ->
            let
                tsCode =
                    elmProgram
                        |> TypeScript.Generator.generate elmVersion
            in
            case tsCode of
                Ok generatedTsCode ->
                    generatedFiles generatedTsCode

                Err errorMessage ->
                    parsingError errorMessage

        Err errorMessage ->
            parsingError errorMessage


init : Flags -> ( Model, Cmd msg )
init flags =
    case
        flags.elmProjectConfig
            |> Json.Decode.decodeValue ElmProjectConfig.decoder
    of
        Ok { sourceDirectories, elmVersion } ->
            ( { elmVersion = elmVersion }, requestReadSourceDirectories sourceDirectories )

        Err error ->
            ( { elmVersion = ElmProjectConfig.Elm18 }, printAndExitFailure ("Couldn't parse elm project configuration file: " ++ error) )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReadSourceFiles sourceFileContents ->
            ( model, output model.elmVersion sourceFileContents )


type Msg
    = ReadSourceFiles (List SourceFile)


type alias Flags =
    { elmProjectConfig : Json.Decode.Value
    }


main : Program Flags Model Msg
main =
    Platform.programWithFlags
        { init = init
        , update = update
        , subscriptions = \_ -> readSourceFiles ReadSourceFiles
        }


type alias SourceFile =
    { path : String, contents : String }


port generatedFiles : List { path : String, contents : String } -> Cmd msg


port parsingError : String -> Cmd msg


port requestReadSourceDirectories : List String -> Cmd msg


port readSourceFiles : (List SourceFile -> msg) -> Sub msg


port print : String -> Cmd msg


port printAndExitFailure : String -> Cmd msg


port printAndExitSuccess : String -> Cmd msg
