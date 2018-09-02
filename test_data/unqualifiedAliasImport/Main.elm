port module Main exposing (Flags, Model, emptyIncomingMessage, generatedFiles, getMaybe, inbound, incomingJsonValue, init, main, outgoingArray, outgoingBoolAlias, outgoingJsonValues, outgoingList, outgoingRecord, parsingError, sendTuple, update)

import Aliases exposing (AliasForBool)
import Array
import Json.Decode as Decode
import Json.Encode



-- it shouldn't fail because there are line-comments
{- or block comments -}


type alias Model =
    ()


type alias Flags =
    { elmModuleFileContents : String }


init : Flags -> ( Model, Cmd msg )
init flags =
    -- this shouldn't cause parsing to fail!
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


port incomingJsonValue : (Decode.Value -> msg) -> Sub msg


port emptyIncomingMessage : (() -> msg) -> Sub msg


port outgoingBoolAlias : AliasForBool -> Cmd msg
