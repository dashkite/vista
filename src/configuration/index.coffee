import data from "./data"

Configuration =

  load: ->
    # TODO check for configuration files
    #      ~/.config/vista.yaml or ./vista.yaml
    #      we can use zephyr

    # TODO validate configuration file
    data

export default Configuration