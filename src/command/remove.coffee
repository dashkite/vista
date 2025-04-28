import { pipe } from "@dashkite/joy/function"
import { start } from "@dashkite/joy/iterable"
import log from "@dashkite/kaiko"
import Issues from "#helpers/issues"
import File from "#helpers/file"

command = ( args, options, configuration ) ->

  for { description, comment, glob, exclude } in configuration.files
    log.info
      console: true
      message: "processing: #{ description }"

    await start Issues.remove comment, glob, exclude

    # for await path from Issues.remove comment, glob, exclude
    #   log.info
    #     console: true
    #     message: "processed file [ #{ path } ]"

export default command
