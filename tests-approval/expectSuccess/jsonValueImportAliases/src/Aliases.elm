module Aliases exposing (DecodeAlias, EncodeAlias)

import Json.Decode as JD
import Json.Encode as JE


type alias DecodeAlias =
    JD.Value


type alias EncodeAlias =
    JE.Value
