import log from "@dashkite/kaiko"
import YAML from "js-yaml"
import Todos from "#helpers/todos"

extract = ( args, options, configuration ) ->

  issues = []

  for { description, comment, glob, exclude } in configuration.files

    log.info
      console: true
      message: "processing: #{ description }"

    if configuration.exclude?
      exclude ?= []
      exclude = [ exclude..., configuration.exclude... ]

    for await issue from Todos.extract comment, glob, exclude
      issues.push issue

  if issues.length > 0
    console.log YAML.dump issues

export default extract
