module Ast.Helpers exposing (..)

import Combine exposing (..)
import Combine.Char exposing (..)
import String


type alias Name = String
type alias QualifiedType = List Name
type alias ModuleName = List String
type alias Alias = String


reserved : List Name
reserved = [ "module", "where"
           , "import", "as", "exposing"
           , "type", {-"alias",-} "port"
           , "if", "then", "else"
           , "let", "in", "case", "of"
           ]


reservedOperators : List Name
reservedOperators =  [ "=", ".", "..", "->", "--", "|", ":", "," ]


between_ : Parser s a -> Parser s res -> Parser s res
between_ p = between p p


singleLineComment : Parser s String
singleLineComment =
  lazy <| \() ->
    Combine.string "--" *> regex "[^\n]*" <* (string "\n" <|> (Combine.end *> succeed "end"))


multiLineComment : Parser s String
multiLineComment =
    let
        parseRestOfComment =
            lazy <| \() ->
                manyTill anyChar
                    (choice
                        [ Combine.string "-}" <* succeed ""
                        , lookAhead (Combine.string "{-") *>
                            ((++) <$> multiLineComment <*> parseRestOfComment
                            )
                        ]
                    )
                >>= (String.fromList >> succeed)
    in
  lazy <| \() ->
    Combine.string "{-" *> parseRestOfComment


comments : Parser s String
comments =
  lazy <| \() ->
    singleLineComment <|> multiLineComment


andComments : Parser s String -> Parser s String
andComments parser =
  lazy <| (\() ->
    String.concat
    <$> (many1 (choice [ comments, parser ])))


spaces : Parser s String
spaces =
    andComments (regex "[ \t]*")


spaces_ : Parser s String
spaces_ =
    andComments (regex "[ \t]+")


wsAndComments : Parser s String
wsAndComments =
    andComments whitespace


symbol : String -> Parser s String
symbol k =
  between_ wsAndComments (string k)


initialSymbol : String -> Parser s String
initialSymbol k =
  string k <* spaces_


commaSeparated : Parser s res -> Parser s (List res)
commaSeparated p =
  sepBy1 (string ",") (between_ wsAndComments p)


commaSeparated_ : Parser s res -> Parser s (List res)
commaSeparated_ p =
  sepBy (string ",") (between_ wsAndComments p)


name : Parser s Char -> Parser s String
name p =
  String.cons <$> p <*> regex "[a-zA-Z0-9_]*"


loName : Parser s String
loName =
  let
    loName_ =
      name lower |>
        andThen (\n ->
          if List.member n reserved
          then fail <| "name '" ++ n ++ "' is reserved"
          else succeed n)
  in
    string "_" <|> loName_


upName : Parser s String
upName = name upper


operator : Parser s String
operator =
  regex "[+-/*=.$<>:&|^?%#@~!]+" |>
    andThen (\n ->
      if List.member n reservedOperators
      then fail <| "operator '" ++ n ++ "' is reserved"
      else succeed n)


operatorReference : Parser s String
operatorReference =
    parens operator


functionName : Parser s String
functionName = loName


functionOrOperator : Parser s String
functionOrOperator =
    choice [ functionName
           , operatorReference
           ]



moduleName : Parser s ModuleName
moduleName =
  between_ spaces <| sepBy1 (string ".") upName


