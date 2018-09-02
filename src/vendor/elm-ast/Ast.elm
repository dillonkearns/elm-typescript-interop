module Ast exposing
    ( parseExpression
    , parseStatement
    , parseOpTable
    , parseModule
    , parse )

{-| This module exposes functions for parsing Elm code.

# Parsers
@docs parseExpression, parseStatement, parseOpTable, parseModule, parse

-}

import Combine exposing (end, (<*))

import Ast.BinOp exposing (OpTable, operators)
import Ast.Expression exposing (Expression, expression, Statement, statement, statements, opTable)


{-| Parse an Elm expression. -}
parseExpression : OpTable -> String -> Result (Combine.ParseErr ()) (Combine.ParseOk () Expression)
parseExpression ops = Combine.parse (expression ops <* end)


{-| Parse an Elm statement. -}
parseStatement : OpTable -> String -> Result (Combine.ParseErr ()) (Combine.ParseOk () Statement)
parseStatement ops = Combine.parse (statement ops <* end)


{-| Parse an OpTable from a module. -}
parseOpTable : OpTable -> String -> Result (Combine.ParseErr ()) (Combine.ParseOk () OpTable)
parseOpTable ops = Combine.parse (opTable ops)


{-| Parse an Elm module. -}
parseModule : OpTable -> String -> Result (Combine.ParseErr ()) (Combine.ParseOk () (List Statement))
parseModule ops = Combine.parse (statements ops)


{-| Parse an Elm module, scanning for infix declarations first. -}
parse : String -> Result (Combine.ParseErr ()) (Combine.ParseOk () (List Statement))
parse input =
  case parseOpTable operators input of
    (Ok (state, stream, ops)) ->
      parseModule ops input

    (Err e) ->
      (Err e)
