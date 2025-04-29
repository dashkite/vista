import { $, quotePowerShell } from "zx"

Labels =

  list: ->
    try
      result = await $"gh label list --json name"
      ( JSON.parse result )
        .map ({ name }) -> name
    catch error
      console.error error.toString()
      throw new Error "vista: unable to get labels"
  
  create: ( name, description ) ->
    try
      command =
        name: "gh"
        arguments: [
          "label",
          "create"
          name
          "-d", description
        ]
      result = await $"#{ command.name } #{ command.arguments }"
      console.error result.toString()
    catch error
      console.error do ->
        [ command.name, command.arguments... ]
          .map quotePowerShell
          .join " "
      console.error error.toString()

export default Labels