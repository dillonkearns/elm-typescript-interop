// WARNING: Do not manually modify this file. It was generated using:
// https://github.com/dillonkearns/elm-typescript-interop
// Type definitions for Elm ports

export namespace Main {
  export interface App {
    ports: {
      generatedFiles: {
        subscribe(
          callback: (data: { path: string; contents: string }[]) => void
        ): void;
      };
      parsingError: {
        subscribe(callback: (data: string) => void): void;
      };
      requestReadSourceDirectories: {
        subscribe(callback: (data: string[]) => void): void;
      };
      readSourceFiles: {
        send(data: { path: string; contents: string }[]): void;
      };
      print: {
        subscribe(callback: (data: string) => void): void;
      };
      printAndExitFailure: {
        subscribe(callback: (data: string) => void): void;
      };
      printAndExitSuccess: {
        subscribe(callback: (data: string) => void): void;
      };
    };
  }

  export function fullscreen(flags: { elmProjectConfig: unknown }): Main.App;
  export function embed(
    node: HTMLElement | null,
    flags: { elmProjectConfig: unknown }
  ): Main.App;
  export function worker(flags: { elmProjectConfig: any }): Main.App;
}
