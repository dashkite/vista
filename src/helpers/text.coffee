before = ( target, text ) ->
  if ( m = text.match target )?
    [ matched ] = { index } = m
    text[ 0...index ]
  else text

after = ( target, text ) ->
  if ( m = text.match target )?
    [ matched ] = { index } = m
    text[( index + matched.length ).. -1 ]
  else text

contains = ( target, text ) ->
  ( text.match target )?

export { before, after, contains }