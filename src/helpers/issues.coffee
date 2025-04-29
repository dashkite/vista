import { $, quote } from "zx"
import { after, contains } from "#helpers/text"
import Git from "#helpers/git"
import File from "#helpers/file"
import YAML from "js-yaml"

Format =
  sentence: ( text ) ->
    text.replace /(?:^|\s)\w/, ( c ) -> c.toUpperCase()
  
  title: ( text ) ->
    text.replace /(?:^|\s)\w/g, ( c ) -> c.toUpperCase()

Reference =
  make: ( issue ) ->
    { nameWithOwner: repo } = ( await $"gh repo view --json nameWithOwner" ).json()
    commit = ( await $"git rev-parse HEAD" ).text().trim()
    url = "https://github.com/#{ repo }/blob/#{ commit }/#{ issue.path }#L#{ issue.line }"
    "[View original context.](#{ url })"

Issues =

  # stream is currently the only supported type
  from: ( stream ) ->
    yaml = ""
    yaml += data for await data from stream      
    yield issue for issue in YAML.load yaml

  # transforms a todos reactor into an issue reactor
  build: ( comment ) ->

    tag = ///#{ comment }\s+TODO:?///

    ( reactor ) ->
      for await { todo, type, text, path, line } from reactor
        if todo
          switch type
            when "title"
              yield issue if issue?
              title = Format.title ( after tag, text ).trim()
              issue = { title, path, line }
            when "body"
              body = ( after comment, text ).trim()
              if body.length > 0
                if !issue.body?
                  issue.body = Format.sentence body
                else
                  issue.body += " #{ body }"
      yield issue if issue?

  # converts an issue reactor into commands to create issues
  command: ( project ) ->
   ( reactor ) ->
      for await issue from reactor
        ref = await Reference.make issue
        issue.body ?= ""
        issue.body += "\n\n#{ ref }"
        command = 
          name: "gh"
          arguments: [
            "issue"
            "create"
            "-t", issue.title
            "-b", issue.body
            "-l", "vista"
          ]
        if project?
          command.arguments.push "-p", project
        yield { command, context: { issue }}

export default Issues
