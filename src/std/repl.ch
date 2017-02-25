const context = Object.isolate({
  let $
  let echo = true
  let prompt = "> "

  const charly = require("charly")
  const Math = require("math")
  const fs = require("fs")

  const context = self
  const history = []
})

print(context.charly.LICENSE)

loop {
  let input = context.prompt.prompt()
  let value

  if input == ".exit" {
    break
  }

  try {
    value = io.eval(input, context)
  } catch(e) {
    value = e
  }

  if context.echo {
    Object.pretty_print(value).tap(print)
  }

  context.$ = value
  context.history.push(input)
}

export = context
