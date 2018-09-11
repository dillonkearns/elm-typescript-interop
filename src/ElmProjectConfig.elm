module ElmProjectConfig exposing (ElmProjectConfig, ElmVersion(..), decoder)

import Json.Decode as Decode exposing (Decoder)
import String.Interpolate exposing (interpolate)


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
        (Decode.field "elm-version" Decode.string
            |> Decode.andThen parseVersion18
        )


parseVersion18 : String -> Decoder ElmVersion
parseVersion18 versionString =
    if versionString == elm18VersionString then
        Decode.succeed Elm18

    else
        interpolate "Unsupported elm-version value: `{0}`. I only support the exact value {1}."
            [ versionString
            , toString elm18VersionString
            ]
            |> Decode.fail


elm18VersionString : String
elm18VersionString =
    "0.18.0 <= v < 0.19.0"
