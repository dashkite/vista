import { $ } from "execa"

Git =

  clean: ->
    try
      await $"git diff-index --quiet HEAD"
      true
    catch error      
      false

export default Git