import { $ } from "execa"

Commands =

  run: ( commands ) ->
    for await { command, context } from commands
      try
        result = await $ command.name, command.arguments, lines: false
        yield { success: true, command, output: result.stdio, context }
      catch error
        yield { success: false, command, output: error.stderr, context }

export default Commands