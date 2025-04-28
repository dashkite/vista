import { $ } from "execa"

Git =

  clean: ->
    true
    # try
    #   await $"git diff-index --quiet HEAD"
    #   true
    # catch error      
    #   false

  ls: ( glob ) ->
    try
      result = $"git ls-files #{ glob }"
      for await path from result
        yield path
    catch error
      console.error error  

export default Git