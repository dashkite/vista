import FS from "node:fs"
import dayjs from "dayjs"
import log from "@dashkite/kaiko"
import Logger from "#helpers/logging"
import benchmark from "#helpers/benchmark"
import Git from "#helpers/git"
import Configuration from "../configuration"

Command =

  run: ( command ) ->

    # ignore the commander object itself
    ( args..., options, _ ) ->

      configuration = await Configuration.load()

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
          if ( options.force || ( await Git.clean()))
            command = ( await import("./#{ command }") ).default
            await command args, options, configuration
          else
            log.error
              console: true
              message: "working directory not clean, exiting..."
            process.exit 1
        catch error
          log.error
            console: true
            message: error.message
          process.exit 1
      
      log.info 
        console: true
        message: "finished in #{ duration}s"

export default Command