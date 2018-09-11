# Changelog

All notable changes to
[the `elm-typescript-interop` NPM package](https://www.npmjs.com/package/elm-typescript-interop)
will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Support for Elm 0.19! Just run the `elm-typescript-interop` CLI from the
  directory with your `elm.json` file!

### Changed

- The `--output` keyword argument has been removed. The CLI will now just
  put the TypeScript declaration file (`.d.ts`-file) in the correct location
  for you. If you have a special use-case that requires the output to be different from this,
  please ping me on Slack or open an issue to discuss. Most likely there won't be a need though.
- Instead of passing a list of source files to the `elm-typescript-interop` CLI, it will now
  read your `elm-package.json`. You will get an error if you don't run it from
  your project root.
- Instead of a list of source files, you pass the main Elm file you would like to generate
  TypeScript type definitions for (this file should be the entry point for your Elm app that exposes
  your app's `main` function of type `Program`).

## [0.0.5] - 2018-09-02

### Fixed

- Moved to [`tunguski/elm-ast`](https://github.com/tunguski/elm-ast) to avoid some parsing issues for valid Elm syntax (see [551199](https://github.com/dillonkearns/elm-typescript-interop/commit/551199dd12087ad965df3b4e57d985854b3f2eac)). This fixes [#3](https://github.com/dillonkearns/elm-typescript-interop/issues/3), [#7](https://github.com/dillonkearns/elm-typescript-interop/issues/7).
- Made alias import lookup more robust. This fixes [#5](https://github.com/dillonkearns/elm-typescript-interop/issues/5). You should
  now be able to use aliases that you import from other modules whether you are using a qualified or an unqualified import.
- The error messages when aliases cannot be found are more clear and informative. But they shouldn't occur for valid Elm code now, unless you are referring to an alias that you get from a package. Logic to search through source code from package dependencies may be included in the future but not in this release. Please open a Github issue to discuss this if you find it to be problematic for your use case.
- Improved command line feedback when invalid options are used. This resolves [#1](https://github.com/dillonkearns/elm-typescript-interop/issues/1). This is using [`dillonkearns/elm-cli-options-parser`](https://github.com/dillonkearns/elm-cli-options-parser) under the hood.
