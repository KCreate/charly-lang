const context = Object.isolate({
  let $
  let echo = true
  const context = self
  const history = []
})

let input

loop {
  input = "> ".prompt()

  if input == ".exit" {
    break
  }

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
