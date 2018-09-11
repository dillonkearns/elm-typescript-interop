module ElmProjectConfigTests exposing (suite)

import ElmProjectConfig
import Expect
import Json.Decode as Decode
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "decoder"
        [ test "Elm 0.18 config" <|
            \() ->
                """
{
    "version": "1.0.0",
    "summary": "Elm TypeScript",
    "repository": "https://github.com/dillonkearns/elm-typescript-interop.git",
    "license": "BSD-3-Clause",
    "source-directories": [
        "src",
        "src/vendor/elm-ast"
    ],
    "exposed-modules": [],
    "dependencies": {
        "Bogdanp/elm-combine": "3.1.1 <= v < 4.0.0",
        "dillonkearns/elm-cli-options-parser": "1.0.1 <= v < 2.0.0",
        "elm-community/list-extra": "7.1.0 <= v < 8.0.0",
        "elm-community/result-extra": "2.2.0 <= v < 3.0.0",
        "elm-lang/core": "5.0.0 <= v < 6.0.0",
        "lukewestby/elm-string-interpolate": "1.0.2 <= v < 2.0.0",
        "rtfeldman/hex": "1.0.0 <= v < 2.0.0"
    },
    "elm-version": "0.18.0 <= v < 0.19.0"
}
              """
                    |> Decode.decodeString ElmProjectConfig.decoder
                    |> Expect.equal
                        (Ok
                            { sourceDirectories = [ "src", "src/vendor/elm-ast" ]
                            , elmVersion = ElmProjectConfig.Elm18
                            }
                        )
        , test "Elm 0.18 config with invalid elm-version" <|
            \() ->
                """
{
    "version": "1.0.0",
    "summary": "Elm TypeScript",
    "repository": "https://github.com/dillonkearns/elm-typescript-interop.git",
    "license": "BSD-3-Clause",
    "source-directories": [
        "src",
        "src/vendor/elm-ast"
    ],
    "exposed-modules": [],
    "dependencies": {
        "Bogdanp/elm-combine": "3.1.1 <= v < 4.0.0",
        "dillonkearns/elm-cli-options-parser": "1.0.1 <= v < 2.0.0",
        "elm-community/list-extra": "7.1.0 <= v < 8.0.0",
        "elm-community/result-extra": "2.2.0 <= v < 3.0.0",
        "elm-lang/core": "5.0.0 <= v < 6.0.0",
        "lukewestby/elm-string-interpolate": "1.0.2 <= v < 2.0.0",
        "rtfeldman/hex": "1.0.0 <= v < 2.0.0"
    },
    "elm-version": "0.18.0"
}
              """
                    |> Decode.decodeString ElmProjectConfig.decoder
                    |> Expect.equal
                        (Err "I ran into a `fail` decoder: Unsupported elm-version value: `0.18.0`. I only support the exact values [\"0.18.0 <= v < 0.19.0\", \"0.19.0\"].")
        , test "Elm 0.19 config" <|
            \() ->
                """
{
    "type": "application",
    "source-directories": [
        "../src",
        "src"
    ],
    "elm-version": "0.19.0",
    "dependencies": {
        "direct": {
            "elm/browser": "1.0.0",
            "elm/core": "1.0.0",
            "elm/html": "1.0.0",
            "elm/http": "1.0.0",
            "elm/json": "1.0.0",
            "elm/url": "1.0.0",
            "elm-community/list-extra": "8.0.0",
            "krisajenkins/remotedata": "5.0.0",
            "lukewestby/elm-string-interpolate": "1.0.3"
        },
        "indirect": {
            "elm/regex": "1.0.0",
            "elm/time": "1.0.0",
            "elm/virtual-dom": "1.0.0"
        }
    },
    "test-dependencies": {
        "direct": {},
        "indirect": {}
    }
}
              """
                    |> Decode.decodeString ElmProjectConfig.decoder
                    |> Expect.equal
                        (Ok
                            { sourceDirectories = [ "../src", "src" ]
                            , elmVersion = ElmProjectConfig.Elm19
                            }
                        )
        ]
