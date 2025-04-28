import { $ } from "execa"
import micromatch from "micromatch"

Git =

  clean: ->
    true
    # try
    #   await $"git diff-index --quiet HEAD"
    #   true
    # catch error      
    #   false

  ls: ( glob, exclude = [] ) ->
    try

      for await path from $"git ls-files #{ glob }"
        unless micromatch.isMatch path, exclude
          yield path

    catch error
      console.error error  

export default Git