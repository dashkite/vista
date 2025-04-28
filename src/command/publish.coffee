import { pipe } from "@dashkite/joy/function"
import log from "@dashkite/kaiko"
import Issues from "#helpers/issues"
import File from "#helpers/file"

command = ( args, options, configuration ) ->

  # NOTE we can now use the output from extract
  #      because we can just pipe it into Issues.command
  # commands = do pipe [
  #   ->   Issues.extract comment, glob
  #   Issues.command options.project
  # ]

  commands = do pipe [
    -> File.issues process.stdin
    Issues.command options.project
  ]

  for await _command from commands
    # TODO run the command
    console.log _command

export default command
