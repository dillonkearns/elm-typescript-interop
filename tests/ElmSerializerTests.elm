module ElmSerializerTests exposing (suite)

import Electron.Generator.ElmSerializer
import Electron.Ipc
import Expect
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "elm serializer"
        [ test "case for a single msg with no parameter" <|
            \() ->
                Electron.Ipc.MsgWithData "UploadSchematic" Electron.Ipc.JsonEncodeValue
                    |> Electron.Generator.ElmSerializer.generateCase
                    |> Expect.equal
                        ("""        ShowFeedbackForm ->
            ( "ShowFeedbackForm", Encode.null )" """
                            |> String.trimRight
                        )
        ]
