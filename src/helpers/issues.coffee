import { $, quote } from "zx"
import { after, contains } from "#helpers/text"
import Git from "#helpers/git"
import File from "#helpers/file"
import YAML from "js-yaml"
import * as URLCodex from "@dashkite/url-codex"

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

  extract: ( issue ) ->
    match = issue.body.match /^\[View original context.\]\((.*)\)$/m
    if match?
      try
        url = new URL match[ 1 ]
        url.pathname
        decoded = URLCodex.decode "/{owner}/{repo}/blob/{commit}/{path+}", url.pathname
        line = parseInt url.hash[2...]
        path = decoded.path.join "/"
        { decoded..., path, line }
      catch error
        console.error error.message

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
      do ({ todo, path, line, title, body } = {})
      for await { todo, path, line, title, body } from reactor
        if todo
          if title?
            yield issue if issue?
            issue = { 
              path, line 
              title: Format.title title
            }
          else if body?
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
        if !( await Issues.search issue )?
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
        else
          console.error "ignoring duplicate: #{ issue.title }"

  search: do ({ issues } = {}) ->
    ( issue ) ->
      try
        result = await $"gh issue list --json title,labels,body"
        issues ?= result.json()
      catch error
        throw new Error "unable to load issues:
          are issues enabled for this repo?"
      issues.find ( _issue ) ->
        ( issue.title == _issue.title ) &&
          do ->
            ( ref = Reference.extract _issue )? &&
              ( issue.path == ref.path ) &&
              ( issue.line == ref.line )

export default Issues
