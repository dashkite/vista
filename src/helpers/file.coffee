import FS from "node:fs/promises"
import YAML from "js-yaml"

File =

  lines: ( reactor ) ->
    try
      for await path from reactor
        fh = await FS.open path
        line = 1
        for await text from fh.readLines()
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