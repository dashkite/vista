import FS from "node:fs/promises"
import YAML from "js-yaml"
import { pipe } from "@dashkite/joy/function"
import { start as run } from "@dashkite/joy/iterable"
import log from "@dashkite/kaiko"
import Todos from "#helpers/todos"
import Commands from "#helpers/commands"
import Issues from "#helpers/issues"
import Labels from "#helpers/labels"
import Git from "#helpers/git"

todos = ( args, options, configuration ) ->

  if !( "vista" in await Labels.list())
    await Labels.create "vista", "Created by Vista"

  for { description, comment, glob, exclude } in configuration.files

    log.info
      console: true
      message: "processing: #{ description }"

    await do pipe [
      -> Todos.extract comment, glob, exclude
      Issues.command options.project
      Commands.run options.dryRun
      ( results ) ->
        for await result from results
          if result.output != ""
            console.error result.output
          if !result.success
            throw new Error "conversion failed"
    ]

    if !options.dryRun
      await run Todos.remove comment, glob, exclude

  if !options.dryRun && !( await Git.clean())
    await Git.commit()

export default todos