import * as Fn from "@dashkite/joy/function"
import log from "@dashkite/kaiko"
import Labels from "#helpers/labels"
import Todos from "#helpers/todos"
import Issues from "#helpers/issues"
import Commands from "#helpers/commands"
import Git from "#helpers/git"

todos = ( args, options ) ->

  if ( await Git.clean())

    if !( "vista" in await Labels.list())
      await Labels.create "vista", "Created by Vista"

    command = Fn.pipe [
      Todos.extract
      Issues.command options.project
      Commands.run options.dryRun
      Commands.print
    ]

    await command options

    if !options.dryRun
      await run Todos.remove comment, glob, exclude

    if !options.dryRun && !( await Git.clean())
      await Git.commit()

  else

    log.error
      console: true
      message: "working directory not clean, exiting..."
    process.exit 1

export default todos