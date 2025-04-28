import { pipe } from "@dashkite/joy/function"
{ titleCase, capitalize } = require "@dashkite/joy/text"
import { after, contains } from "#helpers/text"
import Git from "#helpers/git"
import File from "#helpers/file"

Issues =

  extract: ( comment, glob, exclude ) ->

    todos = do pipe [
      -> Git.ls glob, exclude
      File.lines
      Issues.classify comment
      Issues.build comment
    ]

    yield issue for await issue from todos

  # tranforms a line reactor into a classification reactor
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

  # filters a classification reactor into a non-todo line reactor
  remove: ( comment, glob, exclude ) ->

    todos = do pipe [
      -> Git.ls glob, exclude
      File.lines
      Issues.classify comment
    ]

    for await { todo, text, path } from todos
      yield { text, path } if !todo

  # transforms a classification reactor into an issue reactor
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