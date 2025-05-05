import FS from "node:fs"
import dayjs from "dayjs"
import * as Val from "@dashkite/joy/value"
import log from "@dashkite/kaiko"
import Logger from "#helpers/logging"
import benchmark from "#helpers/benchmark"
import Git from "#helpers/git"
import Configuration from "../configuration"

Command =

  run: ( command ) ->

    # ignore the commander object itself
    ( args..., options, _ ) ->

      options = Val.merge options,
        await Configuration.load()

      # configure logging
      if options.verbose
        log.level = "debug"
      else
        log.level = "info"

      log.observe Logger.printer quiet: false

      log.info 
        console: true
        message: "run at #{( dayjs().format "ddd MMM DD h:mm:ss A" )}"

      duration = await benchmark "vista", ->

        log.info
          console: true
          message: "running command [ #{ command } ]"

        try
          command = ( await import("./#{ command }") ).default
          await command args, options
        catch error
          log.error
            console: true
            message: error.message
          process.exit 1
      
      log.info 
        console: true
        message: "finished in #{ duration}s"

export default Command