port module Main exposing (main)

import Aliases


type alias Model =
    ()


type alias Flags =
    { elmModuleFileContents : String }


init : Flags -> ( Model, Cmd msg )
init flags =
    () ! []


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


port outgoingBoolAlias : Aliases.BoolAlias -> Cmd msg
