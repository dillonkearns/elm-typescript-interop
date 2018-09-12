// WARNING: Do not manually modify this file. It was generated using:
// https://github.com/dillonkearns/elm-typescript-interop
// Type definitions for Elm ports

export namespace Elm {
  namespace Login {
    export interface App {
      ports: {
        loginFromElm: {
          subscribe(callback: (data: string) => void): void
        }
        loginToElm: {
          send(data: string): void
        }
        navbarFromElm: {
          subscribe(callback: (data: string) => void): void
        }
        navbarToElm: {
          send(data: string): void
        }
      };
    }
    export function init(options: {
      node?: HTMLElement | null;
      flags: null;
    }): Elm.Login.App;
  }
}