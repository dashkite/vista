import { performance as Performance } from "node:perf_hooks"
import Format from "#helpers/format"

benchmark = ( name, f ) ->
  Performance.mark "#{ name }-start"
  await f()
  Performance.mark "#{ name }-finish"
  { duration } = Performance.measure name, 
    "#{ name }-start", 
    "#{ name }-finish"
  ( Format.round duration / 1000 )

export { benchmark }
export default benchmark