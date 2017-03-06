const Math = require("math")

/*
 * Configuration
 *
 * length - The length (in lines) of the produced wave
 * width - The width (in chars) of the produced wave
 * modifier - The modifier to apply to the sin input
 * delay - The delay (in ms) between the drawing of each line
 * */
const length = 500
const width = 20
const modifier = 0.05
const delay = 10

length.times(->(i) {
  const offset = (Math.sin(i * modifier) * width) + width;

  // Print the star at the calculated offset
  write(" " * (width * 2 - offset))
  print("*")

  // Delay the next render
  sleep(delay)
})
