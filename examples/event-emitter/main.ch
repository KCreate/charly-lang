// Require some stuff
const EventEmitter = require("./event-emitter.ch")
const myEmitter = EventEmitter()

// Register the main events
myEmitter.add_event("data")
myEmitter.add_event("exit")

// Event handlers
myEmitter.add_handler("data", func(data) {
  print("Got data: " + data)
})

myEmitter.add_handler("exit", func(code) {
  print("Exiting!")
  exit(code)
})

// Main event loop
let input
while (true) {
  input = "> ".prompt().trim()

  if (input == "exit") {
    myEmitter.fire_event("exit", 0)
  } else {
    myEmitter.fire_event("data", input)
  }
}
