# Changelog

All notable changes to
[the `elm-typescript-interop` NPM package](https://www.npmjs.com/package/elm-typescript-interop)
will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.0.16] - 2020-01-30

### Fixed
- Support version flag 0.19.1, see https://github.com/dillonkearns/elm-typescript-interop/pull/23.

## [0.0.15] - 2018-09-17

### Changed

- Generate `any` for `Json.Decode.Value`s since this represents something where any
  TypeScript value is valid to send into Elm, and it must be decoded using a Json Decoder.

## [0.0.13] - 2018-09-17

### Added

- Generate a definition for the `worker` function for running headless apps for Elm 18 projects.

## [0.0.12] - 2018-09-17

### Changed

- If you have a `main` function with no annotation you get an error message.

### Fixed

- Some command line arguments printed "TODO" instead of a clear error message.
  The message now indicate that no arguments are accepted by the CLI.

## [0.0.11] - 2018-09-15

### Fixed

- `import Json.Decode as JD` only resolved correctly when it was referred to in a type alias.
  It now resolves correctly when it is used directly in a port declaration.

## [0.0.10] - 2018-09-15

### Fixed

- Aliases to `Json.Decode.Value` and `Json.Encode.Value` are now parsed correctly.
- Import aliases (i.e. `import MyModule as MyModuleAlias exposing (MyType)`) are now
  supported for type alias lookup!

## [0.0.9] - 2018-09-13

### Changed

- Files in `elm-stuff` and `node_modules` are ignored.

## [0.0.8] - 2018-09-13

### Changed

- Improved error message when there is a parser error.

## [0.0.7] - 2018-09-13

### Fixed

- `elm.json` files take precedence over `elm-package.json` files to ensure that the
  latest config is used.

## [0.0.6] - 2018-09-12

### Added

- Support for Elm 0.19! Just run the `elm-typescript-interop` CLI from the
  directory with your `elm.json` file!

### Changed

- Use `unknown` instead of `any` for JSON values. You can always cast it into
  an `any` type. Having `unknown` be the default makes it more clear that these values
  are not safe unless you do explicit type checking. You can read more about the
  `unknown` type (new in TypeScript 3.0) in these references:
  https://stackoverflow.com/a/51439876/383983, https://auth0.com/blog/typescript-3-exploring-tuples-the-unknown-type/
- Instead of passing a list of source files to the `elm-typescript-interop` CLI, it will now
  read your `elm.json` or `elm-package.json`. You will get an error if you don't run it from
  your project root. The CLI tool also generates TypeScript declaration files for each
  module in your app which exposes a `main` function of type `Program`).
- The `--output` keyword argument has been removed. The CLI will now just
  put the TypeScript declaration file (`.d.ts`-file) in the correct location
  for you. If you have a special use-case that requires the output to be different from this,
  please ping me on Slack or open an issue to discuss. Most likely there won't be a need though.

## [0.0.5] - 2018-09-02

### Fixed

- Moved to [`tunguski/elm-ast`](https://github.com/tunguski/elm-ast) to avoid some parsing issues for valid Elm syntax (see [551199](https://github.com/dillonkearns/elm-typescript-interop/commit/551199dd12087ad965df3b4e57d985854b3f2eac)). This fixes [#3](https://github.com/dillonkearns/elm-typescript-interop/issues/3), [#7](https://github.com/dillonkearns/elm-typescript-interop/issues/7).
- Made alias import lookup more robust. This fixes [#5](https://github.com/dillonkearns/elm-typescript-interop/issues/5). You should
  now be able to use aliases that you import from other modules whether you are using a qualified or an unqualified import.
- The error messages when aliases cannot be found are more clear and informative. But they shouldn't occur for valid Elm code now, unless you are referring to an alias that you get from a package. Logic to search through source code from package dependencies may be included in the future but not in this release. Please open a Github issue to discuss this if you find it to be problematic for your use case.
- Improved command line feedback when invalid options are used. This resolves [#1](https://github.com/dillonkearns/elm-typescript-interop/issues/1). This is using [`dillonkearns/elm-cli-options-parser`](https://github.com/dillonkearns/elm-cli-options-parser) under the hood.
