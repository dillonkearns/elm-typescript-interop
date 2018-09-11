module ElmProjectConfig exposing (ElmProjectConfig, decoder)

import Json.Decode as Decode exposing (Decoder)


type alias ElmProjectConfig =
    { sourceDirectories : List String
    , elmVersion : ElmVersion
    }


type ElmVersion
    = Elm18
    | Elm19


decoder : Decoder (List String)
decoder =
    Decode.field "source-directories" (Decode.list Decode.string)
