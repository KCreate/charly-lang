class Todo {
  property title
  property complete

  func constructor(title) {
    @title = title
    @complete = false
  }

  func toggle() {
    @complete = !@complete
    self
  }
}

class TodoList {
  property todos

  func constructor() {
    @todos = []
  }

  func add(title) {
    @todos.push(Todo(title))
    self
  }

  func remove(id) {
    @todos.delete(id)
    self
  }

  func toggle(id) {
    const todo = @todos[id]
    if (todo ! null) {
      todo.toggle()
    }
    self
  }
}

const myList = TodoList()

# input loop
let done = false
let input
while (!done) {

  # Render the todolist
  print("Your Todos:")
  myList.todos.each(func(todo, index) {

    # Get the correct icon
    let icon = "✓".colorize(32)
    if (!todo.complete) {
      icon = "✗".colorize(31)
    }

    # Print the todo
    print(index.colorize(34) + ": " + icon + " " + todo.title)
  })
  print("")

  # Show the menu
  print("
1. Add todo
2. Toggle todo
3. Delete todo
4. Quit application
  ".trim())

  # Get user input
  input = "> ".promptc().to_n()
  write("   ", "\r")

  if (input == 1) {
    myList.add("title > ".prompt().trim())
  } else if (input == 2) {
    myList.toggle("id > ".promptn())
  } else if (input == 3) {
    myList.remove("id > ".promptn())
  } else if (input == 4) {
    done = true
  } else {
    print("Sorry, I don't know that command!")
  }

  print("")
}
