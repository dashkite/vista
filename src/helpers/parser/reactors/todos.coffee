import Text from "#helpers/text"
import Format from "#helpers/format"

Todo =

  start: ( token ) ->
    Text.contains /^\W+todo:?\b/i, token.content

  same: ( token, previous ) ->
    previous? && 
      (( token.line - previous.line ) <= 1) &&
      ( token.path == previous.path )

  title: ( token ) ->
    Format.title ( Text.after /^\W+todo:?\b/i, token.content ).trim()

  body: ( token ) ->
   ( Text.after /^\W+/i, token.content ).trim()

  valid: ( todo ) ->
    # there has to at least be a title
    todo?.title?.length > 0

  finalize: ( todo ) ->
    todo.body = Format.sentence Text.collapse todo.body
    todo

Todos =

  label: ( reactor ) ->

    todo = 0
    previous = undefined

    for await token from reactor
      switch token.type

        when "comment"
          if Todo.start token
            todo++
            yield { token..., todo }
            previous = token
          else if Todo.same token, previous
            yield { token..., todo }
            previous = token
          else
            yield token
            previous = undefined

        when "multiline-comment"
          if Todo.start token
            todo++
            yield { token..., todo }
            previous = undefined
        else
          yield token

  extract: ( reactor ) ->
    index = 0
    current = undefined
    for await token from reactor
      if token.todo?
        if token.todo == index          
          if current.body != ""
            current.body += " #{ Todo.body token }"
          else
            current.body = Todo.body token
        else
          ( yield Todo.finalize current ) if Todo.valid current
          index = token.todo
          current = {
            title: Todo.title token
            body: ""
            token
          }
    ( yield Todo.finalize current ) if Todo.valid current
  
  remove: ( reactor ) ->
    for await { token } from reactor when !token.todo?
      yield token

export default Todos
