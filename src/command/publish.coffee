import { pipe } from "@dashkite/joy/function"
import log from "@dashkite/kaiko"
import Issues from "#helpers/issues"
import Commands from "#helpers/command"

publish = ( args, options, configuration ) ->

  do pipe [
    -> Issues.from process.stdin
    Issues.command options.project
    Commands.run
    ( results ) ->
      issues = []
      for await result from results
        if !result.success
          issues.push result.context.issue
      if issues.length > 0
        console.log YAML.dump issues
  ]

export default publish
