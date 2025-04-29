import { $, quotePowerShell } from "zx"

Commands =
  format: ( command ) ->
    [ command.name, command.arguments... ]
      .map quotePowerShell
      .join " "

  run: ( rehearsal ) ->
   ( commands ) ->
      for await { command, context } from commands
        if rehearsal
          console.error ( Commands.format command ), "\n"
          yield { success: true, command, output, context }
        else
          try
            result = await $"#{ command.name } #{ command.arguments }"
            yield { success: true, command, output: result.toString(), context }
          catch error
            yield { success: false, command, output: error.toString(), context }

export default Commands