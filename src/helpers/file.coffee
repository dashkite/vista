import FS from "node:fs/promises"

File =

  read: ( reactor ) ->
    try
      for await { path, context... } from reactor
        yield {
          path
          context...
          content: await FS.readFile path, "utf8"
        }
      return
      
export default File