import { $ } from "execa"
import { titleCase, capitalize } from "@dashkite/joy/text"
import { after, contains } from "#helpers/text"
import Git from "#helpers/git"
import File from "#helpers/file"
import YAML from "js-yaml"

Reference =
  make: ( issue ) ->
    process = await $"gh repo view --json nameWithOwner"
    console.log process.stdio
    # https://github.com/<organization>/<repo>/blob/<commit>/<path>#L<line>g

Issues =

  # stream is currently the only supported type
  from: ( stream ) ->
    yaml = ""
    yaml += data for await data from stream      
    yield issue for issue in YAML.load yaml

  # transforms a todos reactor into an issue reactor
  build: ( comment ) ->

    tag = ///#{ comment }\s+TODO///

    ( reactor ) ->
      for await { todo, type, text, path, line } from reactor
        if todo
          switch type
            when "title"
              yield issue if issue?
              title = titleCase ( after tag, text ).trim()
              issue = { title, path, line }
            when "body"
              body = ( after comment, text ).trim()
              if body.length > 0
                if !issue.body?
                  issue.body = capitalize body
                else
                  issue.body += " #{ body }"
      yield issue if issue?

  # converts an issue reactor into commands to create issues
  command: ( project ) ->
   ( reactor ) ->
      await Reference.make()
      for await issue from reactor
        command = 
          name: "gh"
          arguments: [
            "issue"
            "create"
            "-t", issue.title
            "-b", issue.body ? ""
            "-l", "vista"
          ]
        if project?
          command.arguments.push "-p", project
        yield { command, context: { issue }}

export default Issues