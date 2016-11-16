class Event {
  property name
  property handlers

  func constructor(name) {
    @name = name
    @handlers = []
  }

  func register(function) {
    @handlers.push(function)
    self
  }

  func fire(data) {
    @handlers.each(func(handler) {
      handler(data)
    })
    self
  }
}

class EventEmitter {
  property events

  func constructor() {
    @events = {}
  }

  func add_event(name) {
    @events[name] = Event(name)
    self
  }

  func add_handler(name, function) {
    @events[name].register(function)
    self
  }

  func fire_event(name, data) {
    @events[name].fire(data)
    self
  }
}

export = EventEmitter
