module ElmProjectConfig exposing (ElmProjectConfig, ElmVersion(..), decoder)

import Json.Decode as Decode exposing (Decoder)
import List exposing (concat, member)
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

    else if member versionString elm19VersionStrings then
        Decode.succeed Elm19

    else
        interpolate "Unsupported elm-version value: `{0}`. I only support the exact values [{1}]."
            [ versionString
            , concat [ [ elm18VersionString ], elm19VersionStrings ]
                |> List.map toString
                |> String.join ", "
            ]
            |> Decode.fail


elm18VersionString : String
elm18VersionString =
    "0.18.0 <= v < 0.19.0"


elm19VersionStrings : List String
elm19VersionStrings =
    [ "0.19.0", "0.19.1" ]
