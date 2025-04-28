command = ( args, options, configuration ) ->
  # NOTE we can now use the output from extract
  #      because we can just pipe it into Issues.command
  # commands = do pipe [
  #   ->   Issues.extract comment, glob
  #   Issues.command options.project
  # ]

export default command