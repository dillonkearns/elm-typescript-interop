// WARNING: Do not manually modify this file. It was generated using:
// https://github.com/dillonkearns/elm-typescript-interop
// Type definitions for Elm ports

export namespace Elm {
  namespace Main {
    export interface App {
      ports: {
        fromElmInt: {
          subscribe(callback: (data: unknown) => void): void
        }
        toElmInt: {
          send(data: unknown): void
        }
      };
    }
    export function init(options: {
      node?: HTMLElement | null;
      flags: unknown;
    }): Elm.Main.App;
  }
}