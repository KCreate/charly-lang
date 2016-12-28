const context = Object.isolate({
  let $
  let echo = true

  const charly = require("charly")
  const Math = require("math")

  const context = self
  const history = []
})

print(context.charly.LICENSE)

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
