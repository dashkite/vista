import FS from "node:fs"
import Path from "node:path"
import { program } from "commander"
import Command from "./command"
import { $ } from "zx"

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
  .command "extract"
  .description "extract todos from source files"
  .action Command.run "extract"

program
  .command "publish"
  .description "convert issues into GitHub tickets"
  .option "-n, --dry-run", "Show gh commands but don't execute them"
  .option "-p, --project <name>", "Project name for adding issues"
  .action Command.run "publish"
  
program
  .command "remove"
  .description "remove todos from source files"
  .action Command.run "remove"

program
  .command "todos"
  .description "extract and remove todos and create issues"
  .option "-n, --dry-run", "Show gh commands but don't execute them"
  .option "-p, --project <name>", "Project name for adding issues"
  .action Command.run "todos"

# global options
for command in program.commands
  command
    .option "-v, --verbose", "Perform debug logging"
    .option "-f, --force", "Probably no"

program.parseAsync()