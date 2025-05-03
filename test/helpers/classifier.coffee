import Todos from "#helpers/todos"

Lines =

  from: ( lines ) ->
    i = 0
    current = undefined
    for line in lines
      if line.path != current
        current = line.path
        i = 0
      yield { line..., line: i++ }

Classifier =
  
  test: ( scenario ) ->
    lines = Lines.from scenario.lines 
    classify = Todos.classify scenario.comments
    todo for await todo from classify lines

export default Classifier