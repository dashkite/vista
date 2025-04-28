import { pipe } from "@dashkite/joy/function"
{ titleCase, capitalize } = require "@dashkite/joy/text"
import { after, contains } from "#helpers/text"
import Git from "#helpers/git"
import File from "#helpers/file"

Issues =

  extract: ( comment, glob ) ->

    todos = do pipe [
      -> Git.ls glob
      File.lines
      Issues.classify comment
      Issues.build comment
    ]

    yield issue for await issue from todos


  classify: ( comment ) ->

    todo = "#{ comment } TODO"
    parsing = false

    ( reactor ) ->
      for await { text, path, line } from reactor
        if contains todo, text
          parsing = true
          yield { todo: true, type: "title", text, path, line }
        else if parsing && contains comment, text
          yield { todo: true, type: "body", text, path, line }
        else
          parsing = false
          yield { todo: false, text, path, line }

  build: ( comment ) ->
    ( reactor ) ->
      for await { todo, type, text, path, line } from reactor
        if todo
          switch type
            when "title"
              yield issue if issue?
              title = titleCase ( after todo, text ).trim()
              issue = { title, path, line }
            when "body"
              body = ( after comment, text ).trim()
              if body.length > 0
                if !issue.body?
                  issue.body = capitalize body
                else
                  issue.body += " #{ body }"
      yield issue if issue?

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