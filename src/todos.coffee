{ $ } = require "execa"
YAML = require "js-yaml"
{ titleCase, capitalize } = require "@dashkite/joy/text"

after = ( target, text ) ->
  if ( i = text.indexOf target ) >= 0
    text.substr ( i + target.length )
  else text

parse = do ({ re } = {}) ->
  re = ///
    ((\D*))             # path: everything up to the line number
    (?=[:\-]\d+)        # provided that delimiter (: or -) follows
    (?:[:\-])           # then discard the delimiter
    (\d+)               # line number
    (?:[:\-])           # discard next delimiter
    (.*)$               # text
  ///  

  do ({ match, path, number, text } = {}) ->
    ( text ) ->
      if ( match = text.match re )?
        [ , path, , number, text ] = match
        { path, number: ( parseInt number ), text }
      else
        throw new Error "unexpected input: #{ text }"  

todos = ( prefix, extension ) ->
  pattern = "^#{ prefix } TODO"
  glob = "*.#{ extension }"
  try
    # r = recursive, n = line nos
    # A = lines after
    result = $"grep
      -rne #{ pattern }
      --exclude-dir node_modules
      --exclude-dir build
      --exclude-dir .sky
      --exclude-dir .masonry
      --include #{ glob }
      -A 20"

    parsing = false
    issue = undefined
    for await line from result when line != "--"
      { text, path, number } = parse line
      if text.startsWith "#{ prefix } TODO"
        parsing = true
        yield issue if issue?
        issue =
          title: titleCase ( after "#{ prefix } TODO ", text ).trim()
          path: path
          line: number
      else if parsing && text.startsWith prefix
        body = ( after prefix, text ).trim()
        if body.length > 0
          if !issue.body?
            issue.body = capitalize body
          else
            issue.body += " #{ body }"
      else
        parsing = false
    yield issue
        
  catch error
    if error.constructor.name == "ExecaError"
      # grep exists with code 1 if no results
      if error.stderr != ""
        console.error error.stderr
        process.exit 1
    else
      console.error error
      process.exit 1

issues = []
for await issue from todos "#", "coffee"
  issues.push issue
for await issue from todos "#", "yaml"
  issues.push issue
for await issue from todos "//-", "pug"
  issues.push issue
for await issue from todos "//", "pug"
  issues.push issue
for await issue from todos "//", "styl"
  issues.push issue

console.log YAML.dump issues