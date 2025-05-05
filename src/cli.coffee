import FS from "node:fs"
import Path from "node:path"
import { program } from "commander"
import Command from "./command"
import { $ } from "zx"

# TODO Allow configuration of file-type to tokenizer mapping (ex: `.foo` files use the `foo` tokenizer)

# TODO Give precedence to file extension for generating the mapping and fallback to (or remove) MIME type check

# TODO Provide an option for including dot-files (or remove that as a default?)

# TODO Allow configuration file to be passed as an option

# TODO Add more tests

# TODO Rename the command and repositor to _Todos_

# TODO Rename the `todos` command to `track`

# we'll handle our own output thank you
$.quiet = true

program
  .version do ({ path, json, pkg } = {}) ->
    path = Path.join __dirname, "..", "..", "..", "package.json"
    try
      json = FS.readFileSync path, "utf8"
      pkg = JSON.parse json
      pkg.version
    catch
      console.log "vista: error reading package.json"
  .enablePositionalOptions()

program
  .command "print"
  .description "extract todos and print them to the console"
  .action Command.run "print"
  .option "-x, --exclude <patterns...>", "Exclude files"
  .option "--yaml", "Format output as YAML"

# program
#   .command "remove"
#   .description "remove todos from source files"
#   .action Command.run "remove"

program
  .command "todos"
  .description "extract and remove todos and create issues"
  .option "-x, --exclude <patterns...>", "Exclude files"
  .option "-p, --project <name>", "Project name for adding issues"
  .action Command.run "todos"

# global options
for command in program.commands
  command
    .option "-v, --verbose", "Perform debug logging"

program.parseAsync()