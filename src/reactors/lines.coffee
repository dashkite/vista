import FS from "node:fs/promises"

lines = ( reactor ) ->
  try
    for await path from reactor
      fh = await FS.open path
      for await line from fh.readLines()
        yield line
  catch error
    console.error error

export default lines