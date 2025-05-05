
Format =
  
  round: do ({ formatter } = {}) -> 
    ( n ) ->
      formatter ?= Intl.NumberFormat "en",
        minimumFractionDigits: 2
        maximumFractionDigits: 2
      formatter.format n

  sentence: ( text ) ->
    text.replace /(?:^|\s)\w/, ( c ) -> c.toUpperCase()
  
  title: ( text ) ->
    text.replace /(?:^|\s)\w/g, ( c ) -> c.toUpperCase()

export default Format
