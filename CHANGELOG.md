# Changelog

All notable changes to
[the `elm-typescript-interop` NPM package](https://www.npmjs.com/package/elm-typescript-interop)
will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- Moved to [`tunguski/elm-ast`](https://github.com/tunguski/elm-ast) to avoid some parsing issues for valid Elm syntax (see [551199](https://github.com/dillonkearns/elm-typescript-interop/commit/551199dd12087ad965df3b4e57d985854b3f2eac)). This fixes [#3](https://github.com/dillonkearns/elm-typescript-interop/issues/3), [#7](https://github.com/dillonkearns/elm-typescript-interop/issues/7).
- Made alias import lookup more robust. This fixes [#5](https://github.com/dillonkearns/elm-typescript-interop/issues/5). You should
  now be able to use aliases that you import from other modules whether you are using a qualified or an unqualified import.
- The error messages when aliases cannot be found are more clear and informative. But they shouldn't occur for valid Elm code now, unless you are referring to an alias that you get from a package. Logic to search through source code from package dependencies may be included in the future but not in this release. Please open a Github issue to discuss this if you find it to be problematic for your use case.
