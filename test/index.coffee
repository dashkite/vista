import assert from "@dashkite/assert"
import { test, success } from "@dashkite/amen"
import print from "@dashkite/amen-console"

import Comment from "#helpers/comment"

do ->

  print await test "DashKite Vista", [

    test "comment specifier", [

      test "simple inline", ->
        assert.deepEqual ( Comment.specifier "#" ),
          inline: /#/

      test "simple block", ->

        assert.deepEqual ( Comment.specifier inline: "#", block: "###" ),
          inline: /#/
          block:
            begin: /###/
            end: /###/

      test "block w/implicit end", ->
        specifier = Comment.specifier
          inline: "#"
          block:
            begin: "###"
            end: "###"
        assert.deepEqual specifier,
          inline: /#/
          block:
            begin: /###/
            end: /###/

    ]

  ]

  process.exit if success then 0 else 1