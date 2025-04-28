import { titleCase, capitalize } from "@dashkite/joy/text"
import { after, contains } from "#helpers/text"
import Git from "#helpers/git"
import File from "#helpers/file"

Issues =

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
      for await issue from reactor
        command = "gh issue create -t #{ issue.title } -l vista"
        if issue.body?
          command += " -b #{ issue.body }"
        if project?
          command += " -p #{ project }"
        yield command

export default Issues