import { $ } from "execa"

reactor = ( glob ) ->
  try
    result = $"git ls-files #{ glob }"
    for await path from result
      yield path
  catch error
    console.error error

export default reactor