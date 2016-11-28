const context = {
  let $
  const context = self
}

let input

while ((input = "> ".prompt()) ! ".exit") {

  try {
    context.$ = io.eval(input, context)
  } catch(e) {
    context.$ = e
  }

  # Different coloring based on their types
  if (context.$.typeof() == "String") {
    print(context.$.colorize(32))
  } else if (
    (context.$.typeof() == "Numeric") ||
    (context.$.typeof() == "Boolean") ||
    (context.$.typeof() == "Object") ||
    (context.$.typeof() == "Class") ||
    (context.$.typeof() == "Function") ||
    (context.$.typeof() == "PrimitiveClass")) {
    print(context.$.colorize(33))
  } else if (context.$.typeof() == "Null") {
    print(context.$.colorize(30))
  } else {
    print(context.$)
  }
}

export = context
