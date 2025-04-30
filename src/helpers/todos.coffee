import { pipe } from "@dashkite/joy/function"
{ titleCase, capitalize } = require "@dashkite/joy/text"
import { after, contains } from "#helpers/text"
import Git from "#helpers/git"
import File from "#helpers/file"
import Issues from "#helpers/issues"
import Comment from "#helpers/comment"

Todos =

  extract: ( comment, glob, exclude ) ->

    do pipe [
      -> Git.ls glob, exclude
      File.lines
      Todos.classify comment
      Issues.build comment
      ( issues ) ->
        yield issue for await issue from issues
        return
    ]


  # tranforms a line reactor into a classification reactor
  classify: ( specifier ) ->

    do ({ comment } = {}) ->

      try
        comment = Comment.specifier specifier
      catch
        throw new Error "unable to parse configuration"

      # mini-classifier that determines whether a line
      # is a comment or not

      prepare = ( reactor ) ->
        do ( block = false ) ->
          for await { text, context... } from reactor
            if block
              if text.match comment.block.end
                block = false
                yield { text, context..., comment: true }
              else
                yield { text, context..., comment: true }
            else
              if comment.block? && text.match comment.block.begin
                block = true
                yield { text, context..., comment: true }
              else if text.match comment.inline
                yield { text, context..., comment: true }
              else
                yield { text, context..., comment: false }
              
      ( reactor ) ->
        do ( todo = false, { comment } = {}) ->
          for await { text, comment, path, line } from prepare reactor
            # TODO need to make sure the todo is after the comment delimiter
            if comment && contains /\btodo:?\b/i, text
              todo = true
              yield { todo, type: "title", comment, text, path, line }
            else if comment && todo
              yield { todo, type: "body", comment, text, path, line }
            else
              todo = false
              yield { todo, comment, text, path, line }

  # filters a classification reactor into a non-todo line reactor
  remove: ( comment, glob, exclude ) ->

    do pipe [
      -> Git.ls glob, exclude
      File.lines
      Todos.classify comment
      ( todos ) ->
        do ( empty = false, current = undefined ) ->
          for await { todo, text, path } from todos
            if path != current
              current = path
              empty = true
            if !todo
              empty = false
              yield { text, path } 
          if empty then yield text: "", path: current
      File.writer
    ]


export default Todos