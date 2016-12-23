const width = "How wide should the pyramid be?: ".promptn() + 1

width.times(func(i) {

  // Draw the left padding
  (width - i).times(func() {
    write(" ")
  })

  // Draw the pyramid
  i.times(func() {
    write(" *")
  })

  // next line
  write("\n")
})
