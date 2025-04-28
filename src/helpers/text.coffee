after = ( target, text ) ->
  if ( m = text.match target )?
    [ matched ] = { index } = m
    text.substr ( index + matched.length )
  else text

contains = ( target, text ) ->
  ( text.match target )?

export { after, contains }