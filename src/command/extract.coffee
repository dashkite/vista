import log from "@dashkite/kaiko"
import YAML from "js-yaml"
import Issues from "#helpers/issues"

command = ( args, options, configuration ) ->

  issues = []

  for { description, comment, glob } in configuration.files
    log.info
      console: true
      message: "processing: #{ description }"

    for await issue from Issues.extract comment, glob
      issues.push issue

  console.log YAML.dump issues

export default command

