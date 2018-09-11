module ElmProjectConfig exposing (ElmProjectConfig, ElmVersion(..), decoder)

import Json.Decode as Decode exposing (Decoder)


type alias ElmProjectConfig =
    { sourceDirectories : List String
    , elmVersion : ElmVersion
    }


type ElmVersion
    = Elm18
    | Elm19


decoder : Decoder ElmProjectConfig
decoder =
    Decode.map2 ElmProjectConfig
        (Decode.field "source-directories" (Decode.list Decode.string))
        (Decode.succeed Elm18)
