# Vista

*Extract todos into GitHub tickets*

[![Hippocratic License HL3-CORE](https://img.shields.io/static/v1?label=Hippocratic%20License&message=HL3-CORE&labelColor=5e2751&color=bc8c3d)](https://firstdonoharm.dev/version/3/0/core.html)


Vista allows you to extract _todo_ comments from your source and turns them into GitHub issues. It will decorate those issues with permalinks back to the source where the _todo_ originated. It will also remove those comments from your source code, so that Vista can be used as part of your workflow, without worring about accidentally creating duplicate issues.

Each step in this process is also available as a subcommand, which may be run independently.

You can also add the result issues to a project with the `--project` option.

## Background

We often leave reminders in our code that look something like this:

```coffeescript
# TODO a thing to do
#      some additional description
```

These can be converted into GitHub issues with the following fields:

```yaml
title: A Thing To Do
body: Some additional description.
```

In turn, these issues could be added to projects.

## Usage

Just run `vista`.

A typical usage pattern for Vista looks like this: run Vista to create issues from the _todos_ in the source and then review the newly created issues on GitHub, using the including reference links back to the source.

You can run any step in the process using commands. For example, you can extract the _todos_ into a YAML file without creating GitHub issues by running: `vista todos`.

Errors are always logged to `stderr`. 

## Commands

Running Vista without a subcommand will do the equivalent of:

`( vista todos | vista issues ) && vista clear`

### todos

The `todos` command searches the source files in a respository to find all the todos and writes them to `stdout`.

### issues

The `issues` command reads YAML formatted issue entries from `stdin`. An GitHub issue for the repository will be created for each valid entry. The working directory must be clean or the `issues` command will exit with a warning. This ensures that the source code references included in the issues are correct.

The `--project` option (also available when running Vista with no subcommand) will add new issues to the given project.

Any _todos_ for which Vista is unable to create an issue for will be written to `stdout`. Since errors are logged to `stderr`, it’s a good idea to redirect `stdout` to a file:

`vista issues < todos.yaml > failed.yaml`

### clear

The `clear` command will remove todos in all source files in the repository. The working directory must be clean. If there are changed source files, these will be committed with the message `vista clear`.

## Configuration

Vista will look for configuration files in the following locations:

1. In the local directory, as `vista.yaml`.
2. In the home directory, as `.config/vista.yaml`

If no configuration is defined, Vista will use a default configuration.

The configuration includes an array of file types and comment patterns. For example, the following configuration extracts _todos_ from CoffeeScript files:

```yaml
targets:
  - glob: *.coffee
    comment: "^#"
```

## Error Recovery

Vista’s subcommands allow you to recover from errors. If any failures are encountered, Vista will not remove the _todos_ from your source. If the _todos_ were successfully extracted, any that were not successfully converted to issues will be written to `stdout`. Thus, it’s a good idea to redirect `stdout` to a file to make it easier to recover from errors.

To recover, simply run `vista issues` again, redirecting `stdin` using the _todos_ file that was generated initially. Once you’re sure all the _todos_ have been converted, you can run` vista clear`.

