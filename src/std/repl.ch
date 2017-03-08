const REPL = require("repl")
const main = REPL(

  // Insert new context variables here
  {}.tap(->(ctx) {}),

  // Insert new REPL commands here
  {}.tap(->(cmd) {})
)
main.start()
