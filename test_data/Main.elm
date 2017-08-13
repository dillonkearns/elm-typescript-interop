port module Main exposing (..)

import Array
import Json.Encode


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


port generatedFiles : String -> Cmd msg


port parsingError : String -> Cmd msg


port inbound : (Int -> msg) -> Sub msg


port getMaybe : (Maybe Bool -> thisIsAMsg) -> Sub thisIsAMsg


port sendTuple : Maybe ( String, Int, Int ) -> Cmd msg


port outgoingList : List ( Int, Int ) -> Cmd msg


port outgoingArray : Array.Array String -> Cmd msg


port outgoingRecord : { id : Int, username : String, avatarUrl : String } -> Cmd msg


port outgoingJsonValues : List Json.Encode.Value -> Cmd msg
