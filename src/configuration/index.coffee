import * as Val from "@dashkite/joy/value"
import Zephyr from "@dashkite/zephyr"
import data from "./data"

Configuration =

  load: ->
    if ( local = await Zephyr.read "vista.yaml" )?
      Val.merge data, local
    else
      data

export default Configuration