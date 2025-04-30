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
          yield { success: true, command, output: "", context }
        else
          try
            result = await $"#{ command.name } #{ command.arguments }"
            output = result.toString().trim()
            yield { success: true, command, output, context }
          catch error
            output = error.toString().trim()
            yield { success: false, command, output, error, context }

export default Commands