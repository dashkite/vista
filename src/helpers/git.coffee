import _Path from "node:path"
import { $ } from "zx"
import ignore from "ignore"
import MIME from "mime"
import { MediaType } from "@dashkite/media-type"
import log from "@dashkite/kaiko"

Path =

  language: ( path ) ->
    if ( mime = MIME.getType path )?
      if ( type = MediaType.parse mime )?
        type.subtype
    else
      extension = _Path.extname path
      if extension != ""
        extension[1..]

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

  ls: ({ glob, exclude }) ->

    glob ?= []
    exclude ?= []

    # return files that are or could be in git using:
    #
    #   git ls-files #{ glob } -co --exclude-standard
    #
    # we use the -co flags so that we always get everything
    # even if there are uncommitted changes
    #
    # we need --exclude-standard with -o
    #
    # we use ignore for exclude instead of -x
    # b/c it has no effect when using -c

    filter = ignore().add exclude
  
    for await path from $"git ls-files -co --exclude-standard"
      unless filter.ignores path
        if ( language = Path.language path )?
          yield { path, language }
        else
          log.warn
            console: true
            message: "vista: unable to infer language 
              from path [ #{ path } ]"

export default Git