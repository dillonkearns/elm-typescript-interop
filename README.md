# Elm-Electron

Code generator for type-safe elm-electron interprocess messages.

## Usage
* `cd` into your `electron` project.
* `npm install --save-dev elm-electron`.
* Add a script in your `package.json` `scripts` section similar to:
```javascript
"scripts": {
  ...
  "elm-ipc": "elm-electron src/Ipc.elm --output src/ipc.ts"
}
```
Where `src/Ipc.elm` is the location of your `Ipc.Msg` union type and `src/ipc.ts` is the location where you would like to save the generated typescript discriminated union.
* Import the generated code in your Electron nodejs typescript code with `import { Ipc } from 'src/ipc.ts'` (or whatever the relative path to your generated file is).
