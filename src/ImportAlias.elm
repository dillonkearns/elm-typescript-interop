module ImportAlias exposing (ImportAlias)


type alias ImportAlias =
    { unqualifiedModuleName : List String
    , aliasName : String
    , exposed : List String
    }
