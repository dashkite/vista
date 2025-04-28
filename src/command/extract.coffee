import log from "@dashkite/kaiko"
{ $ } = require "execa"
YAML = require "js-yaml"
{ titleCase, capitalize } = require "@dashkite/joy/text"

import files from "#reactors/files"
import lines from "#reactors/lines"
import { after, contains } from "#helpers/text"
import Git from "#helpers/git"

todos = ( comment, glob ) ->
  todo = "#{ comment } TODO"
  pattern = "^\\s*#{ todo }"

  try
    for await path from lines files glob
      yield path

  #   # r = recursive, n = line nos
  #   # A = lines after
  #   result = $"grep
  #     -rne #{ pattern }
  #     --exclude-dir node_modules
  #     --exclude-dir build
  #     --exclude-dir .sky
  #     --exclude-dir .masonry
  #     --include #{ glob }
  #     -A 20"

  #   parsing = false
  #   issue = undefined
  #   for await line from result when line != "--"
  #     { text, path, number } = parse line
  #     if contains todo, text
  #       parsing = true
  #       yield issue if issue?
  #       issue =
  #         title: titleCase ( after todo, text ).trim()
  #         path: path
  #         line: number
  #     else if parsing && contains comment, text
  #       body = ( after comment, text ).trim()
  #       if body.length > 0
  #         if !issue.body?
  #           issue.body = capitalize body
  #         else
  #           issue.body += " #{ body }"
  #     else
  #       parsing = false
  #   yield issue
        
  # catch error
  #   if error.constructor.name == "ExecaError"
  #     # grep exists with code 1 if no results
  #     if error.stderr != ""
  #       console.error error.stderr
  #       process.exit 1
  #   else
  #     console.error error
  #     process.exit 1

command = ( args, options, configuration ) ->

  issues = []
  for { description, comment, glob } in configuration.files
    log.info
      console: true
      message: "processing: #{ description }"
    for await issue from todos comment, glob
      issues.push issue

  console.log YAML.dump issues

export default command

