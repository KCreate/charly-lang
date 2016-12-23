// Initialize some vars
let weight = 0
let height = 0
let bmi = 0

weight = "Enter your weight in KG: ".promptn()
height = "Enter your height in meters: ".promptn()

bmi = weight / height**2
print("Your BMI is: " + bmi)
