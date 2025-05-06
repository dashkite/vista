import FS from "node:fs/promises"
import Prism from "prismjs"
import loader from "prismjs/components/"

normalize = ( token, context = {}) ->
  if !token.type?
    { content: token, length: token.length, context... }
  else
    { ( flatten token )..., context... }

# since we only care about comments, we can flatten nested tokens
flatten = ( token ) ->
  if Array.isArray token.content
    content = ""
    for _token in token.content
      content += ( normalize _token ).content
    length = content.length
    { token..., content, length }
  else
    token

Token =

  tokenize: ( reactor ) ->
    for await { path, content, language, context... } from reactor
      if !Prism.languages[ language ]?
        loader [ language ]
      if !Prism.languages[ language ]?
        throw new Error "vista: unknown language 
          [ #{ language } ] for [ #{ path }]"
      tokens = Prism.tokenize content, Prism.languages[ language ]
      for token from tokens
        yield { path, language, context..., token }

  normalize: ( reactor ) ->
    for await { token, context... } from reactor
      yield normalize token, context

  decorate: ( reactor ) ->
    do ({ offset, line, path } = {}) ->
      for await token from reactor
        if token.path != path
          path = token.path
          offset = 0
          line = 1
        yield { token..., offset, line }
        line += ( token.content.split("\n").length - 1 )
        offset += token.length

  writer: ( reactor ) ->
    path = undefined
    current = ""
    for await token from reactor
      if token.path != path
        if path?
          await FS.writeFile path, current
        path = token.path
        current = token.content
      else
        current += token.content
    if path?
      FS.writeFile path, current

        
export default Token