import assert from "@dashkite/assert"
import { test, success } from "@dashkite/amen"
import print from "@dashkite/amen-console"

import Comment from "#helpers/comment"
import Todos from "#helpers/todos"

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

    test "extract todos", [

      test "classifier", [

        test "inline comment", [

          test "simple todo", ->

            lines = ->
              yield text: "not a comment", path: "a", line: 1
              yield text: "# comment", path: "a", line: 2
              yield text: "# todo title", path: "a", line: 3
              yield text: "#      body text", path: "a", line: 4

            classify = Todos.classify "#"
            
            result = ( todo for await todo from classify lines())

            assert !result[0].todo
            assert !result[1].todo
            assert result[1].comment?
            assert result[2].todo
            assert.equal "title", result[2].title
            assert result[3].todo
            assert.equal "body text", result[3].body

          test "todo at end of file", ->

            lines = ->
              yield text: "not a comment", path: "a", line: 1
              yield text: "# not a todo", path: "a", line: 2
              yield text: "# todo title", path: "a", line: 3
              yield text: "#      body text", path: "a", line: 4
              yield text: "# not a todo", path: "b", line: 1

            classify = Todos.classify "#"
            
            result = ( todo for await todo from classify lines())

            assert !result[4].todo

        ]

      ]


    ]
    


  ]

  process.exit if success then 0 else 1