module OutputPath exposing (declarationPathFromMainElmPath)

import Regex


declarationPathFromMainElmPath : String -> String
declarationPathFromMainElmPath mainFilePath =
    mainFilePath
        |> Regex.replace Regex.All (Regex.regex ".elm/?$") (\_ -> "/index.d.ts")
