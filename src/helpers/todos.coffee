import { pipe } from "@dashkite/joy/function"
{ titleCase, capitalize } = require "@dashkite/joy/text"
import { before, after, contains } from "#helpers/text"
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

      # TODO move reactors into their own files

      prepare = ( reactor ) ->
        do ({current, block, text, path, context } = {}) ->
          current = undefined
          block = false
          for await { text, path, context... } from reactor
            if current != path
              current = path
              block = false
            if block
              if text.match comment.block.end
                block = false
                yield {
                  text, path, context...
                  comment: ( before comment.block.end, text ).trim()
                }
              else
                yield {
                  text, path, context...
                  comment: text.trim()
                }
            else
              if comment.block? && text.match comment.block.begin
                block = true
                yield { 
                  text, path, context...
                  comment: ( after comment.block.begin, text ).trim()
                }
              else if text.match comment.inline
                yield { 
                  text, path, context...
                  comment: ( after comment.inline, text ).trim()
                }
              else
                yield { text, path, context... }
              
      # TODO allow block comments to be followed by inline
      # comment presently, an inline comment following a
      # block comment is parsed as if it were part of the
      # block comment.

      ( reactor ) ->
        do ({ todo, current, text, comment, path, line } = {}) ->
          todo = false
          current = undefined
          for await { text, comment, path, line } from prepare reactor
            if current != path
              current = path
              todo = false
            if comment? && contains /\b^todo:?\b/i, comment
              todo = true
              yield { 
                text, path, line, comment, todo
                title: ( after /\b^todo:?\b/i, comment ).trim()
              }
            else if comment? && todo
              yield { 
                text, path, line, comment, todo
                body: comment.trim()
              }
            else
              todo = false
              yield { text, path, line, comment, todo }

  # filters a classification reactor into a non-todo line reactor
  remove: ( comment, glob, exclude ) ->
    do pipe [
      -> Git.ls glob, exclude
      File.lines
      Todos.classify comment
      ( todos ) ->
        do ({ empty, current, todo, text, path } = {}) ->
          empty = false
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