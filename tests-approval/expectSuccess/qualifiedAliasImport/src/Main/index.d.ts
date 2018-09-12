// WARNING: Do not manually modify this file. It was generated using:
// https://github.com/dillonkearns/elm-typescript-interop
// Type definitions for Elm ports

export namespace Main {
  export interface App {
    ports: {
      outgoingBoolAlias: {
        subscribe(callback: (data: boolean) => void): void
      }
    };
  }

  export function fullscreen(flags: { elmModuleFileContents: string }): Main.App;
  export function embed(node: HTMLElement | null, flags: { elmModuleFileContents: string }): Main.App;
}