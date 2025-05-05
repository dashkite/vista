import * as Fn from "@dashkite/joy/function"
import * as It from "@dashkite/joy/iterable"
import Todos from "#helpers/todos"
import Issues from "#helpers/issues"

print = ( args, options ) ->

  command = Fn.pipe [
    Todos.extract
    Issues.print options
  ]

  await command options

export default print