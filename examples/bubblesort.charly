let numbers = []
let amount = "How many numbers do you want to sort?: ".promptn()
print("Enter " + amount.colorize(32) + " numbers: ")

amount.times(func() {
  numbers.push("> ".promptn())
})

numbers = numbers.sort(func(left, right) {
  left < right
})

print(numbers)
