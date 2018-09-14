module IntAliasMain exposing (main)

import Browser
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import IntAlias as ThisIsAnImportAlias


port fromElmInt : { key : String, value : List ThisIsAnImportAlias.Alias } -> Cmd msg


port toElmInt : (ThisIsAnImportAlias.Alias -> msg) -> Sub msg


type alias Model =
    { count : Int }


init : Flags -> Model
init flags =
    { count = 0 }


type Msg
    = Increment
    | Decrement


update : Msg -> Model -> Model
update msg model =
    case msg of
        Increment ->
            { model | count = model.count + 1 }

        Decrement ->
            { model | count = model.count - 1 }


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick Increment ] [ text "+1" ]
        , div [] [ text <| String.fromInt model.count ]
        , button [ onClick Decrement ] [ text "-1" ]
        ]


type alias Flags =
    ThisIsAnImportAlias.Alias


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        }
