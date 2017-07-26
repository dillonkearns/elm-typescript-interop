port module Main exposing (..)


type alias Model =
    ()


init : ( Model, Cmd msg )
init =
    () ! [ sayHi "Hello from Elm!!!" ]


update : msg -> Model -> ( Model, Cmd msg )
update msg model =
    model ! []


main : Program Never Model msg
main =
    Platform.program
        { init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        }


port sayHi : String -> Cmd msg
