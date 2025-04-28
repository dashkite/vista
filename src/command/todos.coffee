import YAML from "js-yaml"
import { pipe } from "@dashkite/joy/function"
import { start as run } from "@dashkite/joy/iterable"
import log from "@dashkite/kaiko"
import Todos from "#helpers/todos"
import Commands from "#helpers/commands"
import Issues from "#helpers/issues"
import Labels from "#helpers/labels"

todos = ( args, options, configuration ) ->

  if !( "vista" in await Labels.list())
    await Labels.create "vista", "Created by Vista"

  for { description, comment, glob, exclude } in configuration.files

    log.info
      console: true
      message: "processing: #{ description }"

    issues = []
    await do pipe [
      -> Todos.extract comment, glob, exclude
      Issues.command options.project
      Commands.run
      ( results ) ->
        for await result from results
          console.error result.output
          if !result.success
            issues.push result.context.issue
        if issues.length > 0
          console.log YAML.dump issues
    ]

    if issues.length == 0
      await run Todos.remove comment, glob, exclude

export default todos