import { pipe } from "@dashkite/joy/function"
import log from "@dashkite/kaiko"
import Issues from "#helpers/issues"
import File from "#helpers/file"

command = ( args, options, configuration ) ->

  for { description, comment, glob, exclude } in configuration.files
    log.info
      console: true
      message: "processing: #{ description }"

    removed = do pipe [
      -> Issues.remove comment, glob, exclude
      File.writer 
    ]

    for await path from removed
      log.info
        console: true
        message: "updated file [ #{ path } ]"

export default command
