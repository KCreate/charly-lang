class REPL {
  static property default_commands
  static property default_context

  property context
  property commands

  func constructor(context, commands) {
    @commands = Object.assign({}, REPL.default_commands, commands)
    @context = Object.assign({}, REPL.default_context, context)
  }

  func start() {
    @commands["startup"](self)

    let input
    let value
    loop {
      input = gets(@context.prompt, true)

      if input[0] == "." {
        const command = input.substring(1)
        const available_commands = Object.keys(@commands)

        if available_commands.includes(command) {
          @commands[command](self)
          continue
        } else {
          print("Couldn't find command: " + command)
          print("Available commands are:")

          available_commands.each(->(cmd) {
            print("  - " + cmd)
          })

          continue
        }
      }

      try {
        value = eval(input, @context)
      } catch(e) {
        value = e
      }

      if @context.echo {
        Object.pretty_print(value).tap(print)
      }

      @context.$ = value
      @context.history.push(input)
    }
  }
}

REPL.default_commands = {}.tap(->(cmd) {
  cmd["exit"] = ->(repl) {
    exit(0)
  }

  cmd["startup"] = ->(repl) {
    print(repl.context.charly.LICENSE)
  }
})

REPL.default_context = Object.isolate({}.tap(->(ctx) {
  ctx["$"] = null
  ctx["echo"] = true
  ctx["prompt"] = "> "
  ctx["context"] = ctx
  ctx["history"] = []

  ctx["charly"] = require("charly")
  ctx["math"] = require("math")
  ctx["fs"] = require("fs")
}))

export = REPL
