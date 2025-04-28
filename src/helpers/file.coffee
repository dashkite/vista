import FS from "node:fs/promises"
import YAML from "js-yaml"

File =

  lines: ( reactor ) ->
    try
      for await path from reactor
        # I tried usin FS.open with  FS.readlines here
        # but we were somehow dropping trailing newlines
        content = await FS.readFile path, "utf8"
        line = 1
        for text in content.split "\n"
          yield { text, line, path }
          line++
      return

  issues: ( reactor ) ->
    yaml = ""
    yaml += data for await data from reactor      
    yield issue for issue in YAML.load yaml

  writer: ( reactor ) ->
    for await line from reactor
      if line.path != path
        if lines?.length > 0
          await FS.writeFile path, lines.join "\n"
          yield path
        path = line.path
        lines = [ line.text ]
      else
        lines.push line.text
    if lines?.length > 0
      await FS.writeFile path, lines.join "\n"
      yield path
    
export default File