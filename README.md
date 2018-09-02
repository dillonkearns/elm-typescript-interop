# Elm TypeScript Interop
[![Build Status](https://travis-ci.org/dillonkearns/elm-typescript-interop.svg?branch=master)](https://travis-ci.org/dillonkearns/elm-typescript-interop)
[![npm version](https://badge.fury.io/js/elm-typescript-interop.svg)](https://badge.fury.io/js/elm-typescript-interop)

Use type-safe ports between Elm and TypeScript for end-to-end type-safety!

We love the safety and guarantees that Elm gives us. But we accept that we must give those up in our native javascript code for our Elm applications and the seams between the two languages. `elm-typescript-interop` gives the same guarantees of no runtime exceptions for sending and receiving data between Elm and TypeScript. If your code compiles, you have the guarantee that the data you're sending will be what Elm is expecting. No more unexpected data runtime errors from Elm!

## Elm Ports Vs. Elm-TypeScript-Interop Ports
The [Elm Guide](https://guide.elm-lang.org/interop/javascript.html) describes all the supported types for javascript interop. Note that this is improved with elm-typescript-interop:

    Booleans and Strings – both exist in Elm and JS!
    Numbers – Elm ints and floats correspond to JS numbers
    Lists – correspond to JS arrays
    Arrays – correspond to JS arrays
    Tuples – *correspond to TypeScript tuples in elm-typescript-interop
    Records – correspond to JavaScript objects *(with type-safety)
    Maybes – Nothing and Just 42 correspond to null and 42 in JS
             *In elm-typescript-interop, the type will be (number | null)
    Json – Json.Encode.Value corresponds to arbitrary JSON


### Elm <-> TypeScript Type Conversions
To learn more about the types in TypeScript, see https://basarat.gitbooks.io/typescript/docs/types/type-system.html.

`Json.Encode.Value` <-> `any`  Avoid this escape hatch when possible. If your TypeScript value may take on multiple types, use this type paired with a decoder.

`Boolean` <-> `boolean`

`String` <-> `string`

`Maybe Boolean` <-> `boolean | null`

`Int` or `Float` <-> `number`

`List String` or `Array String`  <-> `string[]`
(or other types besides String, of course)

`{ username: String, id: Int }` <-> `{ username: string; id: number}`

`(Int, String)` <-> `[Int, String]`

With regular Elm JS interop, the recommended approach is to use decoders so you can more gracefully handle unexpected types rather than ending execution with a runtime exception. With elm-typescript-interop, it is actually *safer* to use raw types because they are guaranteed to match up. With the caveat that you lose this guarantee if you are passing in something with an `any` type, in this case it is better to make this uncertainty explicit by declaring the type as a `Json.Decode.Value`.
This is no longer the case when you use `elm-typescript-interop`.

The recommended approach with `elm-typescript-interop` is the opposite: avoid
using Json.Encode.Value for ports and flags. Using Elm types here allows us to
have guaranteed type-safety between Elm and TypeScript, so there's no need to use
a decoder to safely handle unexpected types. With `elm-typescript-interop`, it is
recommended that you use `Json.Encode.Value` only if for some reason a
TypeScript type cannot be known at compile-time.


Both are excellent resources, and this was true with the limitations of javascript.
TypeScript provides type-safety and more expressive types that allow us to
interoperate better with Elm.

## Usage
See [github.com/dillonkearns/elm-typescript-starter](https://github.com/dillonkearns/elm-typescript-starter) for reference or to setup a brand new project.

See [github.com/dillonkearns/mobster](https://github.com/dillonkearns/mobster)
for a real-world example of this library in action.

* `cd` into your typescript project.
* `npm install --save-dev elm-typescript-interop`.
* Configure your package.json scripts to run `elm-typescript-interop` before each build.
