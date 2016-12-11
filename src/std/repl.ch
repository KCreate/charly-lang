const context = {
  let $
  let echo = true
  const context = self
  const history = []
}

let input

while ((input = "> ".prompt()) ! ".exit") {

  try {
    context.$ = io.eval(input, context)
  } catch(e) {
    context.$ = e
  }

  if context.echo {
    print(context.$.pretty_print())
    context.history.push(input)
  }
}

export = context
