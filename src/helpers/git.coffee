import { $ } from "zx"
import micromatch from "micromatch"

Git =

  commit: ->
    try
      result = await $"git add -A . && 
        git commit -m 'vista: converted todos into GitHub Issues'"
      console.error result.toString().trim()
    catch error
      console.error error.toString().trim()

  clean: ->
    try
      await $"git diff-index --quiet HEAD"
      true
    catch error      
      false

  ls: ( glob, exclude = [] ) ->
    try

      for await path from $"git ls-files #{ glob }"
        unless micromatch.isMatch path, exclude
          yield path

    catch error
      console.error error  

export default Git