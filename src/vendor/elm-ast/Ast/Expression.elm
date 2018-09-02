module Ast.Expression exposing
    ( Expression(..)
    , expression
    , ExportSet(..)
    , Type(..)
    , Statement(..)
    , Function(..)
    , LetBinding(..)
    , Parameter(..)
    , statement
    , statements
    , infixStatements
    , opTable )

{-| This module exposes parsers for Elm expressions.

# Types
@docs Expression, ExportSet, Type, Statement, Function, LetBinding, Parameter

# Parsers
@docs expression, statement, statements, infixStatements, opTable

-}

import Char
import Combine exposing (..)
import Combine.Char exposing (..)
import Combine.Num
import Dict exposing (Dict)
import List exposing (singleton)
import List.Extra exposing (break)
import String
import Hex
import Regex

import Ast.BinOp exposing (..)
import Ast.Helpers exposing (..)

type Collect a
  = Cont a
  | Stop a

{-| Representations for Elm's expressions. -}
type Expression
  = Character Char
  | String String
  | Integer Int
  | Float Float
  | Variable (List Name)
  | FqnAdt (List Name)
  | TupleExpr (List Expression)
  | OperatorReference String
  | List (List Expression)
  | Access Expression (List Name)
  | Record (List (Name, Expression))
  | RecordUpdate Name (List (Name, Expression))
  | If Expression Expression Expression
  | Let (List LetBinding) Expression
  | Case Expression (List (Expression, Expression))
  | Lambda (List Parameter) Expression
  | Application Expression Expression
  | BinOp Expression Expression Expression
  | NamedExpression Expression Name


character : Parser s Expression
character =
    Character
        <$> between_ (Combine.string "'")
                (((Combine.string "\\" *> regex "(n|t|r|\\\\|x..)")
                    >>= (\a ->
                            case String.uncons a of
                                Just ( 'n', "" ) ->
                                    succeed '\n'

                                Just ( 't', "" ) ->
                                    succeed '\t'

                                Just ( 'r', "" ) ->
                                    succeed '\x0D'

                                Just ( '\\', "" ) ->
                                    succeed '\\'

                                Just ( '0', "" ) ->
                                    succeed '\x00'

                                Just ( 'x', hex ) ->
                                    hex
                                        |> String.toLower
                                        |> Hex.fromString
                                        |> Result.map Char.fromCode
                                        |> Result.map succeed
                                        |> Result.withDefault (fail "Invalid charcode")

                                Just other ->
                                    fail ("No such character as \\" ++ toString other)

                                Nothing ->
                                    fail "No character"
                        )
                 )
                    <|> anyChar
                )

string : Parser s Expression
string =
  let
    singleString =
      String
        <$> (Combine.string "\"" *> regex "([\\\\][\\\\]|[\\\\]\"|[^\"\n])*" <* Combine.string "\"")

    multiString  =
      (String << String.concat)
        <$> (Combine.string "\"\"\"" *> many (regex "[^\"]*") <* Combine.string "\"\"\"")
  in
    multiString <|> singleString


integer : Parser s Expression
integer =
  Integer
  <$> choice
        [ Combine.string "0x"
          *> regex "[0-9a-fA-F]+"
          |> andThen (\txt ->
              case String.toInt ("0x" ++ txt) of
                  Ok i -> succeed i
                  _ -> fail "Not a number"
          )
        , Combine.Num.int
        ]


float : Parser s Expression
float =
  Float <$> Combine.Num.float


access : Parser s Expression
access =
  Access <$> variable <*> many1 (Combine.string "." *> loName)


accessFunction : Parser s Expression
accessFunction =
    (Combine.string "." *> loName)
    |> andThen (\name ->
        Lambda [ RefParam "accessedRecord" ]
            (Access (Variable [ "accessedRecord" ]) [ name ])
        |> succeed
    )


variable : Parser s Expression
variable =
  Variable <$> choice [ singleton <$> loName
                      , sepBy1 (Combine.string "." ) upName
                      , (,)
                          <$> (upName <* Combine.string ".")
                          <*> loName
                          |> map (\(p, v) ->
                              [ p, v ]
                          )
                      ]

fqnAdt : Parser s (List String)
fqnAdt =
  choice [ sepBy1 (Combine.string "." ) upName
         , singleton <$> upName
         ]

list : OpTable -> Parser s Expression
list ops =
  lazy <| \() ->
    List <$> brackets (commaSeparated_ (expression ops))


record : OpTable -> Parser s Expression
record ops =
  lazy <| \() ->
    Record <$> braces (commaSeparated_ ((,) <$> loName <*> (symbol "=" *> expression ops)))
    >>= named NamedExpression



simplifiedRecord : Parser s Expression
simplifiedRecord =
    lazy <|
        \() ->
            Record <$> (braces (commaSeparated ((\a -> ( a, Variable [ a ] )) <$> loName)))


recordUpdate : OpTable -> Parser s Expression
recordUpdate ops =
  lazy <| \() ->
     braces (
        RecordUpdate
            <$> (wsAndComments *> loName)
            <*> (symbol "|" *> commaSeparated_ ((,) <$> loName <*> (symbol "=" *> expression ops)))
    )
    >>= named NamedExpression


tuple : OpTable -> Parser s Expression
tuple ops =
    lazy (\_ ->
        TupleExpr <$> (parens <| commaSeparated_ (expression ops))
    )


letExpression : OpTable -> Parser s Expression
letExpression ops =
    lazy <| \() ->
      Let
        <$> (symbol "let" *> (many <| between_ wsAndComments (
                choice
                    [ (maybe functionTypeDeclaration)
                      *> wsAndComments
                      *> (FunctionBinding <$> functionDeclaration ops)
                    , DestructuringBinding
                        <$> (functionParameter ops)
                        <*> (symbol "=" *> expression ops)
                    ]
            )))
        <*> (symbol "in" *> expression ops)


ifExpression : OpTable -> Parser s Expression
ifExpression ops =
  lazy <| \() ->
    If
      <$> (symbol "if" *> expression ops)
      <*> (symbol "then" *> expression ops)
      <*> (symbol "else" *> expression ops)


manyWithLookAhead consumer base repetition =
    lazy <| \() ->
        withLocation (\location ->
            let
                matches =
                    Regex.find
                        (Regex.AtMost 1)
                        (Regex.regex "[|]>|<[|]")
                        location.source
                pos =
                    (case List.head matches of
                        Just match ->
                            min location.column match.index
                        _ ->
                            location.column
                    ) - 1

            in
                consumer
                <$> base
                <*> many
                    ( lookAhead (wsAndComments *>
                        (primitive (\state inputStream ->
                            ( state
                            , inputStream
                            , Ok (pos <= (currentLocation inputStream).column)
                            )
                        )))
                        |> andThen (\isIndented ->
                            case isIndented of
                                True -> wsAndComments *> repetition
                                False -> spaces_ *> repetition
                        )
                    )
        )


caseExpression : OpTable -> Parser s Expression
caseExpression ops =
  let
    binding =
      lazy <| \() ->
        (,)
          <$> (wsAndComments *> expression ops)
          <*> (symbol "->" *> expression ops)
  in
    manyWithLookAhead
        Case
        ((symbol "case" *> expression ops) <* symbol "of")
        binding


lambda : OpTable -> Parser s Expression
lambda ops =
  lazy <| \() ->
    Lambda
      <$> (symbol "\\" *> many (between_ spaces (functionParameter ops)))
      <*> (symbol "->" *> expression ops)


{- Parse function application.
   Parse function arguments as long as _beginning_ of next expression
   is indented more than function name.
-}
application : OpTable -> Parser s Expression
application ops =
    let
        defaultApplication =
            manyWithLookAhead
                (,)
                (term ops)
                (term ops)
            |> map (\(baseTerm, baseList) ->
                case baseList of
                    [] -> baseTerm
                    _ ->
                        let
                            processApplication expr list =
                                case list of
                                    [ x ] -> expr x
                                    h :: t ->
                                        processApplication (Application (expr h)) t
                                    _ -> Debug.crash ("Invalid state" ++ (toString (baseTerm, baseList)))
                        in
                            processApplication (Application baseTerm) baseList
            )
            |> andThen (named NamedExpression)

        minusApplication =
            Application (Variable [ "-" ])
                <$> (symbol "-" *> variable)

    in
        choice
            [ defaultApplication
            , minusApplication
            ]


named : (a -> Name -> a) -> a -> Parser s a
named value expr =
    --succeed expr
    choice [ value expr
             <$> (spaces *> Combine.string "as" *> spaces *> loName)
           , succeed expr
           ]


binary : OpTable -> Parser s Expression
binary ops =
  lazy <| \() ->
    let
      next =
        between_ wsAndComments operator |> andThen (\op ->
          choice [ Cont <$> application ops, Stop <$> expression ops ] |> andThen (\e ->
            case e of
              Cont t -> ((::) (op, t)) <$> collect
              Stop e -> succeed [(op, e)]))

      collect = next <|> succeed []
    in
      application ops |> andThen (\e ->
        collect |> andThen (\eops ->
          split ops 0 e eops))

term : OpTable -> Parser s Expression
term ops =
  lazy <| \() ->
      choice
        [ character
        , string
        , float
        , integer
        , access
        , accessFunction
        , variable
        , OperatorReference <$> operatorReference
        , list ops
        , record ops
        , simplifiedRecord
        , recordUpdate ops
        , parens (expression ops)
        , tuple ops
        , parens (many <| Combine.string ",") |> map (\i ->
                String <| "createTuple" ++ (toString <| List.length i)
            )
        ]

{-| A parser for Elm expressions. -}
expression : OpTable -> Parser s Expression
expression ops =
  lazy <| \() ->
    choice [ letExpression ops
           , caseExpression ops
           , ifExpression ops
           , lambda ops
           , binary ops
           ]

op : OpTable -> String -> (Assoc, Int)
op ops n =
  Dict.get n ops
    |> Maybe.withDefault (L, 9)

assoc : OpTable -> String -> Assoc
assoc ops n = Tuple.first <| op ops n

level : OpTable -> String -> Int
level ops n = Tuple.second <| op ops n

hasLevel : OpTable -> Int -> (String, Expression) -> Bool
hasLevel ops l (n, _) = level ops n == l

split : OpTable -> Int -> Expression -> List (String, Expression) -> Parser s Expression
split ops l e eops =
  case eops of
    [] ->
      succeed e

    _ ->
      findAssoc ops l eops |> andThen (\assoc ->
        sequence (splitLevel ops l e eops) |> andThen (\es ->
          let ops_ = List.filterMap (\x -> if hasLevel ops l x
                                           then Just (Tuple.first x)
                                           else Nothing) eops
          in case assoc of
            R -> joinR es ops_
            _ -> joinL es ops_))

splitLevel : OpTable -> Int -> Expression -> List (String, Expression) -> List (Parser s Expression)
splitLevel ops l e eops =
  case break (hasLevel ops l) eops of
    (lops, (_, e_)::rops) ->
      split ops (l + 1) e lops :: splitLevel ops l e_ rops

    (lops, []) ->
      [ split ops (l + 1) e lops ]

joinL : List Expression -> List String -> Parser s Expression
joinL es ops =
  case (es, ops) of
    ([e], []) ->
      succeed e

    (a::b::remE, op::remO) ->
      joinL ((BinOp (Variable [op]) a b) :: remE) remO

    _ ->
      fail ""

joinR : List Expression -> List String -> Parser s Expression
joinR es ops =
  case (es, ops) of
    ([e], []) ->
      succeed e

    (a::b::remE, op::remO) ->
      joinR (b::remE) remO |> andThen (\e ->
        succeed (BinOp (Variable [op]) a e))

    _ ->
      fail ""

findAssoc : OpTable -> Int -> List (String, Expression) -> Parser s Assoc
findAssoc ops l eops =
  let
    lops = List.filter (hasLevel ops l) eops
    assocs = List.map (assoc ops << Tuple.first) lops
    error issue =
      let operators = List.map Tuple.first lops |> String.join " and " in
      "conflicting " ++ issue ++ " for operators " ++ operators
  in
    if List.all ((==) L) assocs then
      succeed L
    else if List.all ((==) R) assocs then
      succeed R
    else if List.all ((==) N) assocs then
      case assocs of
        [_] -> succeed N
        _   -> fail <| error "precedence"
    else
      fail <| error "associativity"


------------------------------------------------------------------------------
-- Statements
------------------------------------------------------------------------------


{-| Representations for modules' exports. -}
type ExportSet
  = AllExport
  | SubsetExport (List ExportSet)
  | FunctionExport Name
  | TypeExport Name (Maybe ExportSet)


{-| Representations for Elm's type syntax. -}
type Type
  = TypeConstructor QualifiedType (List Type)
  | TypeVariable Name
  | TypeRecordConstructor Type (List (Name, Type))
  | TypeRecord (List (Name, Type))
  | TypeTuple (List Type)
  | TypeApplication Type Type
  | NamedType Type Name


{-| Representation for Elm's functions' parameter structure -}
type Parameter
    = RefParam String
    | AdtParam (List String) (List Parameter)
    | TupleParam (List Parameter)
    | RecordParam (List Parameter)
    | NamedParam Parameter Name


{-| Function declaration type -}
type Function
    = Function Name (List Parameter) Expression


{-| Let binding type -}
type LetBinding
    = FunctionBinding Function
    | DestructuringBinding Parameter Expression


{-| Representations for Elm's statements. -}
type Statement
  = ModuleDeclaration ModuleName ExportSet
  | EffectsModuleDeclaration ModuleName Expression ExportSet
  | PortModuleDeclaration ModuleName ExportSet
  | ImportStatement ModuleName (Maybe Alias) (Maybe ExportSet)
  | TypeAliasDeclaration Type Type
  | TypeDeclaration Type (List Type)
  | PortTypeDeclaration Name Type
  | PortDeclaration Name (List Name) Expression
  | FunctionTypeDeclaration Name Type
  | FunctionDeclaration Function
  | InfixDeclaration Assoc Int Name
  | Comment String


-- Exports
-- -------


allExport : Parser s ExportSet
allExport =
  AllExport <$ symbol ".."


functionExport : Parser s ExportSet
functionExport =
  FunctionExport <$> functionOrOperator


constructorSubsetExports : Parser s ExportSet
constructorSubsetExports =
  SubsetExport <$> commaSeparated (FunctionExport <$> upName)


constructorExports : Parser s (Maybe ExportSet)
constructorExports =
  maybe <| parens <| choice [ allExport
                            , constructorSubsetExports
                            ]


typeExport : Parser s ExportSet
typeExport =
  TypeExport <$> (upName <* spaces) <*> constructorExports


subsetExport : Parser s ExportSet
subsetExport =
  SubsetExport
    <$> commaSeparated (functionExport |> or typeExport)


exports : Parser s ExportSet
exports =
  parens <| choice [ allExport, subsetExport ]


-- Types
-- -----
typeVariable : Parser s Type
typeVariable =
  TypeVariable <$> loName

typeConstant : Parser s Type
typeConstant =
  TypeConstructor <$> sepBy1 (Combine.string ".") upName <*> succeed []

typeApplication : Parser s (Type -> Type -> Type)
typeApplication =
  TypeApplication <$ symbol "->"

typeTuple : Parser s Type
typeTuple =
  lazy <| \() ->
      parens (commaSeparated_ ( choice [ typeAnnotation, type_ ] ))
      |> map (\list ->
          case list of
              [ a ] -> a
              _ -> TypeTuple list
      )

typeRecordPair : Parser s (Name, Type)
typeRecordPair =
  lazy <| \() ->
    (,) <$> (loName <* symbol ":") <*> typeAnnotation

typeRecordPairs : Parser s (List (Name, Type))
typeRecordPairs =
  lazy <| \() ->
    commaSeparated_ typeRecordPair

typeRecordConstructor : Parser s Type
typeRecordConstructor =
  lazy <| \() ->
    braces
      <| TypeRecordConstructor
           <$> (between_ spaces typeVariable)
           <*> (symbol "|" *> typeRecordPairs)

typeRecord : Parser s Type
typeRecord =
  lazy <| \() ->
    braces
      <| TypeRecord <$> typeRecordPairs


typeConstructor : Parser s Type
typeConstructor =
    lazy <| \() ->
        manyWithLookAhead
            TypeConstructor
            (sepBy1 (Combine.string ".") upName)
            type_


type_ : Parser s Type
type_ =
  lazy <| \() ->
    between_ spaces <| choice [ typeConstructor
                              , typeVariable
                              , typeRecordConstructor
                              , typeRecord
                              , typeTuple
                              , parens typeAnnotation
                              ]


typeAnnotation : Parser s Type
typeAnnotation =
  lazy <| \() ->
    type_ |> chainr typeApplication


-- Modules
-- -------


effectsModuleDeclaration : Parser s Statement
effectsModuleDeclaration =
  EffectsModuleDeclaration
    <$> (initialSymbol "effect" *> symbol "module" *> moduleName)
    <*> (symbol "where" *> record operators)
    <*> (symbol "exposing" *> exports)


portModuleDeclaration : Parser s Statement
portModuleDeclaration =
  PortModuleDeclaration
    <$> (initialSymbol "port" *> symbol "module" *> moduleName)
    <*> (symbol "exposing" *> exports)


moduleDeclaration : Parser s Statement
moduleDeclaration =
  ModuleDeclaration
    <$> (initialSymbol "module" *> moduleName)
    <*> (symbol "exposing" *> exports)


-- Imports
-- -------
importStatement : Parser s Statement
importStatement =
  ImportStatement
    <$> (initialSymbol "import" *> moduleName)
    <*> maybe (symbol "as" *> upName)
    <*> maybe (symbol "exposing" *> exports)


-- Type declarations
-- -----------------
typeAliasDeclaration : Parser s Statement
typeAliasDeclaration =
  TypeAliasDeclaration
    <$> (initialSymbol "type" *> symbol "alias" *> type_)
    <*> (wsAndComments *> symbol "=" *> typeAnnotation)

typeDeclaration : Parser s Statement
typeDeclaration =
  TypeDeclaration
    <$> (initialSymbol "type" *> type_)
    <*> (wsAndComments *> symbol "=" *> (sepBy1 (symbol "|") (between_ wsAndComments typeConstructor)))


-- Ports
-- -----


portTypeDeclaration : Parser s Statement
portTypeDeclaration =
  PortTypeDeclaration
    <$> (initialSymbol "port" *> loName)
    <*> (symbol ":" *> typeAnnotation)


portDeclaration : OpTable -> Parser s Statement
portDeclaration ops =
  PortDeclaration
    <$> (initialSymbol "port" *> loName)
    <*> (many <| between_ spaces loName)
    <*> (symbol "=" *> expression ops)


-- Functions
-- ---------


functionTypeDeclaration : Parser s Statement
functionTypeDeclaration =
  FunctionTypeDeclaration
  <$> (functionOrOperator <* symbol ":")
  <*> typeAnnotation


functionDeclaration : OpTable -> Parser s Function
functionDeclaration ops =
  Function
    <$> functionOrOperator
    <*> (many (between_ wsAndComments (functionParameter ops)))
    <*> (symbol "=" *> wsAndComments *> expression ops)


functionParameter : OpTable -> Parser s Parameter
functionParameter ops =
    lazy (\_ ->
        choice
            [ RefParam <$> loName
            , AdtParam <$> fqnAdt <*> (many (between_ wsAndComments (functionParameter ops)))
                >>= named NamedParam
            , TupleParam <$> (parens <| commaSeparated_ (functionParameter ops))
                >>= named NamedParam
            , RecordParam <$> (braces <| commaSeparated (RefParam <$> loName))
                >>= named NamedParam
            ]
    )


-- Infix declarations
-- ------------------


infixDeclaration : Parser s Statement
infixDeclaration =
  InfixDeclaration
    <$> choice [ L <$ initialSymbol "infixl"
               , R <$ initialSymbol "infixr"
               , N <$ initialSymbol "infix"
               ]
    <*> (spaces *> Combine.Num.int)
    <*> (spaces *> (loName <|> operator))


-- Comments
-- --------


comment : Parser s Statement
comment =
    Comment <$> comments


{-| A parser for stand-alone Elm statements. -}
statement : OpTable -> Parser s Statement
statement ops =
  choice [ effectsModuleDeclaration
         , portModuleDeclaration
         , moduleDeclaration
         , importStatement
         , typeAliasDeclaration
         , typeDeclaration
         , portTypeDeclaration
         , portDeclaration ops
         , functionTypeDeclaration
         , FunctionDeclaration <$> functionDeclaration ops
         , infixDeclaration
         , comment
         ]


{-| A parser for a series of Elm statements. -}
statements : OpTable -> Parser s (List Statement)
statements ops =
  manyTill (wsAndComments *> statement ops <* wsAndComments) end


{-| A scanner for infix statements. This is useful for performing a
first pass over a module to find all of the infix declarations in it.
-}
infixStatements : Parser s (List Statement)
infixStatements =
  let
    statements =
      many ( choice [ Just    <$> infixDeclaration
                    , Nothing <$  regex ".*"
                    ] <* wsAndComments ) <* end
  in
    statements |> andThen (\xs ->
      succeed <| List.filterMap identity xs)

{-| A scanner that returns an updated OpTable based on the infix
declarations in the input. -}
opTable : OpTable -> Parser s OpTable
opTable ops =
  let
    collect s d =
      case s of
        InfixDeclaration a l n ->
          Dict.insert n (a, l) d

        _ ->
          Debug.crash "impossible"
  in
    infixStatements |> andThen (\xs ->
      succeed <| List.foldr collect ops xs)


