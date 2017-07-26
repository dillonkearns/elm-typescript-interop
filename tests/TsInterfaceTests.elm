module TsInterfaceTests exposing (..)

import Electron.Generator.Ts
import Electron.Ipc
import Expect
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "ts interface"
        [ test "with no parameters" <|
            \() ->
                Electron.Ipc.Msg "HideWindow"
                    |> Electron.Generator.Ts.generateInterface
                    |> Expect.equal
                        "interface HideWindow {\n  message: 'HideWindow'\n}"
        ]
