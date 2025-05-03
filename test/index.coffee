import assert from "@dashkite/assert"
import { test, success } from "@dashkite/amen"
import print from "@dashkite/amen-console"

import Comment from "#helpers/comment"

import Classifier from "./helpers/classifier"

import Runner from "@dashkite/runner"
import scenarios from "./scenarios"

do ->

  results = await do ->
    Runner
      .make scenarios
      .apply 

        "comment specifier": 
          "*": ({ specifier }) -> Comment.specifier specifier

        "extract todos":
          "classifier":
            "**": Classifier.test

  print await test "DashKite Vista", results 
  process.exit if success then 0 else 1

