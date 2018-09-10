port module Main exposing (Flags, Model, crashOrOutputString, generatedFiles, init, main, output, parsingError, update, workaround)

import Cli.Option as Option
import Cli.OptionsParser as OptionsParser exposing (with)
import Cli.Program
import Json.Decode exposing (..)
import TypeScript.Data.Program
import TypeScript.Generator
import TypeScript.Parser


type alias CliOptions =
    { outputPath : String
    , sourceFilePaths : List String
    }


programConfig : Cli.Program.Config CliOptions
programConfig =
    Cli.Program.config { version = "0.0.4" }
        |> Cli.Program.add
            (OptionsParser.build CliOptions
                |> with
                    (Option.requiredKeywordArg "output")
                |> OptionsParser.withDoc "initialize a git repository"
                |> OptionsParser.withRestArgs
                    (Option.restArgs "SOURCE FILES")
            )



-- Need to import Json.Decode as a
-- workaround for https://github.com/elm-lang/elm-make/issues/134


workaround : Decoder String
workaround =
    Json.Decode.string


type alias Model =
    ()


output : List String -> String -> Cmd msg
output elmModuleFileContents tsDeclarationPath =
    elmModuleFileContents
        |> TypeScript.Parser.parse
        |> crashOrOutputString tsDeclarationPath


crashOrOutputString : String -> Result String TypeScript.Data.Program.Program -> Cmd msg
crashOrOutputString tsDeclarationPath result =
    case result of
        Ok elmProgram ->
            let
                tsCode =
                    elmProgram
                        |> TypeScript.Generator.generate
            in
            case tsCode of
                Ok generatedTsCode ->
                    generatedFiles
                        { path = tsDeclarationPath
                        , contents = generatedTsCode
                        }

                Err errorMessage ->
                    parsingError errorMessage

        Err errorMessage ->
            parsingError errorMessage


init : Flags -> CliOptions -> ( Model, Cmd msg )
init flags cliOptions =
    ( (), requestReadSourceFiles [ "src" ] )


update : CliOptions -> Msg -> Model -> ( Model, Cmd Msg )
update cliOptions msg model =
    case msg of
        ReadSourceFiles sourceFileContents ->
            ( model, output sourceFileContents cliOptions.outputPath )


type Msg
    = ReadSourceFiles (List String)


type alias Flags =
    Cli.Program.FlagsIncludingArgv {}


main : Cli.Program.StatefulProgram Model Msg CliOptions {}
main =
    Cli.Program.stateful
        { printAndExitFailure = printAndExitFailure
        , printAndExitSuccess = printAndExitSuccess
        , init = init
        , config = programConfig
        , update = update
        , subscriptions = \_ -> readSourceFiles ReadSourceFiles
        }


port generatedFiles : { path : String, contents : String } -> Cmd msg


port parsingError : String -> Cmd msg


port requestReadSourceFiles : List String -> Cmd msg


port readSourceFiles : (List String -> msg) -> Sub msg


port print : String -> Cmd msg


port printAndExitFailure : String -> Cmd msg


port printAndExitSuccess : String -> Cmd msg
