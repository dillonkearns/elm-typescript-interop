module Ast.BinOp exposing
    ( Assoc(..)
    , OpTable
    , operators )

{-| This module exposes functions and types for working with operator
precedence tables.

# Types
@docs Assoc, OpTable

# Misc
@docs operators

-}

import Dict exposing (Dict)

import Ast.Helpers exposing (Name)

{-| FIXME -}
type Assoc
  = N | L | R


{-| FIXME -}
type alias OpTable
  = Dict Name (Assoc, Int)


{-| The default operator precedence table. -}
operators : OpTable
operators =
  Dict.empty
    |> Dict.insert "||"  (L, 2)
    |> Dict.insert "&&"  (L, 3)
    |> Dict.insert "=="  (L, 4)
    |> Dict.insert "/="  (L, 4)
    |> Dict.insert "<"   (L, 4)
    |> Dict.insert ">"   (L, 4)
    |> Dict.insert ">="  (L, 4)
    |> Dict.insert "<="  (L, 4)
    |> Dict.insert "++"  (L, 5)
    |> Dict.insert "+"   (L, 6)
    |> Dict.insert "-"   (L, 6)
    |> Dict.insert "*"   (L, 7)
    |> Dict.insert "/"   (L, 7)
    |> Dict.insert "%"   (L, 7)
    |> Dict.insert "//"  (L, 7)
    |> Dict.insert "rem" (L, 7)
    |> Dict.insert "^"   (L, 8)
    |> Dict.insert "<<"  (L, 9)
    |> Dict.insert ">>"  (L, 9)
    |> Dict.insert "<|"  (R, 0)
    |> Dict.insert "|>"  (R, 0)
