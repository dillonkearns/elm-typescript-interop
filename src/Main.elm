port module Main exposing (Flags, Model, crashOrOutputString, generatedFiles, init, main, output, parsingError, update, workaround)

import Cli.OptionsParser as OptionsParser exposing (with)
import Cli.Program
import ElmProjectConfig exposing (ElmVersion)
import Json.Decode exposing (..)
import TypeScript.Data.Program
import TypeScript.Generator
import TypeScript.Parser


type alias CliOptions =
    ()


programConfig : Cli.Program.Config CliOptions
programConfig =
    Cli.Program.config { version = "0.0.11" }
        |> Cli.Program.add
            (OptionsParser.build ()
                |> OptionsParser.withDoc "generates TypeScript declaration files (.d.ts) based on the flags and ports you define within your Elm app."
            )



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


init : Flags -> CliOptions -> ( Model, Cmd msg )
init flags cliOptions =
    case
        flags.elmProjectConfig
            |> Json.Decode.decodeValue ElmProjectConfig.decoder
    of
        Ok { sourceDirectories, elmVersion } ->
            ( { elmVersion = elmVersion }, requestReadSourceDirectories sourceDirectories )

        Err error ->
            ( { elmVersion = ElmProjectConfig.Elm18 }, printAndExitFailure ("Couldn't parse elm project configuration file: " ++ error) )


update : CliOptions -> Msg -> Model -> ( Model, Cmd Msg )
update cliOptions msg model =
    case msg of
        ReadSourceFiles sourceFileContents ->
            ( model, output model.elmVersion sourceFileContents )


type Msg
    = ReadSourceFiles (List SourceFile)


type alias FlagsExtension =
    { elmProjectConfig : Json.Decode.Value
    }


type alias Flags =
    Cli.Program.FlagsIncludingArgv FlagsExtension


main : Cli.Program.StatefulProgram Model Msg CliOptions FlagsExtension
main =
    Cli.Program.stateful
        { printAndExitFailure = printAndExitFailure
        , printAndExitSuccess = printAndExitSuccess
        , init = init
        , config = programConfig
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
