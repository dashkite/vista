import { $ } from "execa"

Labels =

  list: ->
    try
      result = await $"gh label list --json name"
      ( JSON.parse result.stdout )
        .map ({ name }) -> name
    catch error
      console.error result.stderr
      throw new Error "vista: unable to get labels"
  
  create: ( name, description ) ->
    try
      result = await $ "gh", [
        "label",
        "create"
        name
        "-d", description
      ]
      console.error result.stdout
    catch error
      console.error result.escapedCommand
      console.error result.stderr

export default Labels