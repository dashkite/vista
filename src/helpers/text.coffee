after = ( target, text ) ->
  if ( i = text.indexOf target ) >= 0
    text.substr ( i + target.length )
  else text

contains = ( target, text ) ->
  text.includes target

export { after, contains }