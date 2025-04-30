import * as Obj from "@dashkite/joy/object"
import Generic from "@dashkite/generic"

Comment =

  specifier: do ->

    F = 
      expand: Generic.make "_expand"
      block: Generic.make "_block"
      inline: Generic.make "_inline"

    F.block

      .define [ Obj.has "end" ], ({ end, rest... }) ->
        { 
          end: new RegExp end
        }

      .define [ Obj.has "begin" ], ({ begin, rest... }) ->
        re = new RegExp begin
        { 
          begin: re
          end: re
          ( F.block rest )...
        }

      .define [ String ], ( block ) ->
        re = new RegExp block
        { begin: re, end: re }

    F.expand

      # .define [{}], ->

      .define [ Obj.has "block" ], ({ block, rest... }) ->
        { 
          block: F.block block
        }

      .define [ Obj.has "inline" ], ({ inline, rest... }) ->
        { 
          inline: new RegExp inline
          ( F.expand rest )...
        }

      .define [ String ], ( inline ) -> 
        inline: new RegExp inline

    F.expand

export default Comment