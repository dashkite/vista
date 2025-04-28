import { pipe } from "@dashkite/joy/function"
{ titleCase, capitalize } = require "@dashkite/joy/text"
import { after, contains } from "#helpers/text"
import Git from "#helpers/git"
import File from "#helpers/file"
import Issues from "#helpers/issues"

Todos =

  extract: ( comment, glob, exclude ) ->

    todos = do pipe [
      -> Git.ls glob, exclude
      File.lines
      Todos.classify comment
      Issues.build comment
    ]

    yield issue for await issue from todos

  # tranforms a line reactor into a classification reactor
  classify: ( comment ) ->

    tag = ///#{ comment }\s+TODO///
    parsing = false

    ( reactor ) ->
      for await { text, path, line } from reactor
        if contains tag, text
          parsing = true
          yield { todo: true, type: "title", text, path, line }
        else if parsing && contains comment, text
          yield { todo: true, type: "body", text, path, line }
        else
          parsing = false
          yield { todo: false, text, path, line }

  # filters a classification reactor into a non-todo line reactor
  remove: ( comment, glob, exclude ) ->

    do pipe [
      -> Git.ls glob, exclude
      File.lines
      Todos.classify comment
      ( todos ) ->
        for await { todo, text, path } from todos
          yield { text, path } if !todo
      File.writer
    ]


export default Todos