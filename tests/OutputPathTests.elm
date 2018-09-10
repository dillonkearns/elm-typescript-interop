module OutputPathTests exposing (suite)

import Expect
import OutputPath
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "generator"
        [ test "without trailing slash" <|
            \() ->
                OutputPath.declarationPathFromMainElmPath "./test_data/simple/src/Main.elm"
                    |> Expect.equal "./test_data/simple/src/Main/index.d.ts"
        , test "with trailing slash" <|
            \() ->
                OutputPath.declarationPathFromMainElmPath "./test_data/simple/src/Main.elm/"
                    |> Expect.equal "./test_data/simple/src/Main/index.d.ts"
        ]
