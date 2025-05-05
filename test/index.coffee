import * as Fn from "@dashkite/joy/function"
import * as It from "@dashkite/joy/iterable"

import assert from "@dashkite/assert"
import { test, success } from "@dashkite/amen"
import print from "@dashkite/amen-console"

import Git from "#helpers/git"
import Token from "#helpers/parser/reactors/token"
import Todos from "#helpers/parser/reactors/todos"

import Classifier from "./helpers/classifier"

import Runner from "@dashkite/runner"
import scenarios from "./scenarios"

do ->

  print await test "DashKite Vista",

    await do ->

      Runner

        .make scenarios

        .apply 

          "Git.ls": 
            "*": ({ glob }) -> It.collect Git.ls glob

          "Token.tokenize":
            "*": ({ files }) -> It.collect Token.tokenize files

          "Token.normalize":
            "*": ({ files }) -> 
              It.collect Token.normalize Token.tokenize files

          "Token.decorate":
            "*": ({ files }) -> 
              do Fn.pipe [
                -> files
                Token.tokenize
                Token.normalize
                Token.decorate
                It.collect
              ]

          "Todos.label":
            "*": ({ files }) -> 
              do Fn.pipe [
                -> files
                Token.tokenize
                Token.normalize
                Token.decorate
                Todos.label
                It.collect
              ]

          "Todos.extract":
            "*": ({ files }) -> 
              do Fn.pipe [
                -> files
                Token.tokenize
                Token.normalize
                Token.decorate
                Todos.label
                Todos.extract
                It.collect
              ]

          # "extract todos":
          #   "classifier":
          #     "**": Classifier.test

  process.exit if success then 0 else 1

