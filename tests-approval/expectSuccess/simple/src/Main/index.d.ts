// WARNING: Do not manually modify this file. It was generated using:
// https://github.com/dillonkearns/elm-typescript-interop
// Type definitions for Elm ports

export namespace Main {
  export interface App {
    ports: {
      generatedFiles: {
        subscribe(callback: (data: string) => void): void
      }
      parsingError: {
        subscribe(callback: (data: string) => void): void
      }
      inbound: {
        send(data: number): void
      }
      getMaybe: {
        send(data: boolean | null): void
      }
      sendTuple: {
        subscribe(callback: (data: [string, number, number] | null) => void): void
      }
      outgoingList: {
        subscribe(callback: (data: [number, number][]) => void): void
      }
      outgoingArray: {
        subscribe(callback: (data: string[]) => void): void
      }
      outgoingRecord: {
        subscribe(callback: (data: { id: number; username: string; avatarUrl: string }) => void): void
      }
      outgoingJsonValues: {
        subscribe(callback: (data: any[]) => void): void
      }
      incomingJsonValue: {
        send(data: any): void
      }
      emptyIncomingMessage: {
        send(data: null): void
      }
      outgoingBoolAlias: {
        subscribe(callback: (data: boolean) => void): void
      }
    };
  }

  export function fullscreen(flags: { elmModuleFileContents: string }): Main.App;
  export function embed(node: HTMLElement | null, flags: { elmModuleFileContents: string }): Main.App;
}