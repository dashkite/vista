import * as Fn from "@dashkite/joy/function"
import File from "#helpers/file"
import Git from "#helpers/git"
import Token from "#helpers/parser/reactors/token"
import _Todos from "#helpers/parser/reactors/todos"

extract = Fn.pipe [
  File.read
  Token.tokenize
  Token.normalize
  Token.decorate
  _Todos.label
  _Todos.extract
]

remove = Fn.pipe [
  File.read
  Token.tokenize
  Token.normalize
  Token.decorate
  _Todos.label
  _Todos.remove
  Token.writer
]

Todos =

  extract: ( options ) ->
    extract Git.ls options

  remove: ( options ) ->
    remove Git.ls options

export default Todos