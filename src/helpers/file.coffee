import FS from "node:fs/promises"

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

  writer: ( reactor ) ->
    do ( lines = [], path = undefined ) ->

      for await line from reactor

        if line.path != path
          if lines.length > 0
            await FS.writeFile path, lines.join "\n"
            yield path
          path = line.path
          lines = [ line.text ]

        else
          lines.push line.text

      if lines.length > 0
        await FS.writeFile path, lines.join "\n"
        yield path
      
export default File