import FS from "node:fs"
import Path from "node:path"
import { program } from "commander"
import Command from "./command"

program
  # TODO get version from package.json
  .version do ({ path, json, pkg } = {}) ->
    path = Path.join __dirname, "..", "..", "..", "package.json"
    json = FS.readFileSync path, "utf8"
    pkg = JSON.parse json
    pkg.version
  .enablePositionalOptions()

program
  .command "extract"
  .description "extract todos from source files"
  .action Command.run "extract"

program
  .command "publish"
  .description "convert issues into GitHub tickets"
  .option "-p, --project <name>", "Project name for adding issues"
  .action Command.run "issues"
  
program
  .command "clear"
  .description "remove todos from source files"
  .action Command.run "clear"

program
  .command "todos"
  .description "extract and remove todos and create issues"
  .option "-p, --project <name>", "Project name for adding issues"
  .action Command.run "convert"

# global options
for command in program.commands
  command
    .option "-v, --verbose", "Perform debug logging"

program.parseAsync()