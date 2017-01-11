const context = Object.isolate({
  let $
  let echo = true
  let prompt = "> "

  const charly = require("charly")
  const Math = require("math")

  const context = self
  const history = []
})

print(context.charly.LICENSE)

let input

loop {
  input = context.prompt.prompt()

  if input == ".exit" {
    break
  }

  try {
    context.$ = io.eval(input, context)
  } catch(e) {
    context.$ = e
  }

  if context.echo {
    Object.pretty_print(context.$).tap(print)
    context.history.push(input)
  }
}

export = context
