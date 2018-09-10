port module Main exposing (AliasForBool, Flags, Model, emptyIncomingMessage, generatedFiles, getMaybe, inbound, incomingJsonValue, init, main, outgoingArray, outgoingBoolAlias, outgoingJsonValues, outgoingList, outgoingRecord, parsingError, sendTuple, update)

import Array
import Json.Decode as Decode
import Json.Encode



-- Nested function declarations broke syntax parsing with `Bogdanp/elm-ast`.
-- See https://github.com/dillonkearns/elm-typescript-interop/issues/7.


letFunctionAnnotation : String -> String -> String
letFunctionAnnotation model err =
    let
        errorLog : String -> String
        errorLog err =
            identity err
    in
    err
        |> errorLog
        |> String.slice 0 200
        |> Debug.log "Error occurred"



-- Comments in a function body broke compilation in `Bogdanp/elm-ast`.
-- See https://github.com/dillonkearns/elm-typescript-interop/issues/3


functionWithCommentsInBody : String -> String
functionWithCommentsInBody location =
    let
        currentRoute =
            String.toUpper location
    in
    --( initialModel currentRoute, fetchUser )
    currentRoute


type alias Model =
    ()


type alias AliasForBool =
    Bool


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
