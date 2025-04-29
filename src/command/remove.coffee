import { pipe } from "@dashkite/joy/function"
import { start as run } from "@dashkite/joy/iterable"
import log from "@dashkite/kaiko"
import Todos from "#helpers/todos"
import Git from "#helpers/git"

remove = ( args, options, configuration ) ->

  for { description, comment, glob, exclude } in configuration.files
    log.info
      console: true
      message: "processing: #{ description }"

    await run Todos.remove comment, glob, exclude

  await Git.commit()

export default remove
