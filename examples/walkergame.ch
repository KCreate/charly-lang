class Game {
  property raster
  property width
  property height

  property playerX
  property playerY

  func constructor(width, height) {
    @playerX = 0
    @playerY = 0

    @width = width
    @height = height

    // Construct the raster
    @raster = Array.of_size(@height, null).map(func() {
      Array.of_size(@width, " ")
    })

    // Insert the player
    @raster[@playerY][@playerX] = "#"
  }

  func set_pos(x, y) {

    // Normalize the coordinates
    x = x.min(@width - 1).max(0)
    y = y.min(@height - 1).max(0)

    // Reset the current location
    @raster[@playerY][@playerX] = " "

    // Update the position
    @playerX = x
    @playerY = y

    // Draw the next location
    @raster[y][x] = "#"
  }

  func render() {
    print("__" * (@width + 1))
    @raster.each(func(yRow, y) {
      write("|")
      yRow.each(func(xTile, y) {
        write(xTile + " ")
      })
      write("|\n")
    })
    print("__" * (@width + 1))
  }

  func start() {
    let input
    while (true) {
      input = getc()

      if (input == "q") {
        exit(0)
      } else if (input == "w") {
        @set_pos(@playerX, @playerY - 1)
      } else if (input == "a") {
        @set_pos(@playerX - 1, @playerY)
      } else if (input == "s") {
        @set_pos(@playerX, @playerY + 1)
      } else if (input == "d") {
        @set_pos(@playerX + 1, @playerY)
      }
      @render()
    }
  }
}

let walkerGame = Game(10, 10)
walkerGame.render()
walkerGame.start()
