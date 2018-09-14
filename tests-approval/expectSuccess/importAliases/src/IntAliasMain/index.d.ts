// WARNING: Do not manually modify this file. It was generated using:
// https://github.com/dillonkearns/elm-typescript-interop
// Type definitions for Elm ports

export namespace Elm {
  namespace IntAliasMain {
    export interface App {
      ports: {
        fromElmInt: {
          subscribe(callback: (data: number) => void): void
        }
        toElmInt: {
          send(data: number): void
        }
        fromElmString: {
          subscribe(callback: (data: string) => void): void
        }
        toElmString: {
          send(data: string): void
        }
      };
    }
    export function init(options: {
      node?: HTMLElement | null;
      flags: null;
    }): Elm.IntAliasMain.App;
  }
}
