# Elm-TypeScript

Communicate between your Elm pages and your main NodeJS TypeScript process
with the type-safety your accustomed to in Elm.

![Type-Safe IPC Messages](/demo.gif)

## Usage
See [github.com/dillonkearns/elm-typescript-starter](https://github.com/dillonkearns/elm-typescript-starter) for reference or to setup a brand new project.

See [github.com/dillonkearns/mobster](https://github.com/dillonkearns/mobster)
for a real-world example of this library in action.

* `cd` into your typescript project.
* `npm install --save-dev elm-typescript`.
* Add a script in your `package.json` `scripts` section similar to:
```javascript
"scripts": {
  ...
  "generate-ipc": "elm-typescript src/Ipc.elm --ts src/ipc.ts --elm src/IpcSerializer.elm"
}
```

Where `src/Ipc.elm` is the location of your `Ipc.Msg` union type and `src/ipc.ts` is the location where you would like to save the generated typescript discriminated union.

Import the generated code in your TypeScript nodejs typescript code with `import { Ipc } from 'src/ipc.ts'` (or whatever the relative path to your generated file is).
