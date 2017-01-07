const Math = require("math")

export = ->(describe, it, assert) {

  it("has mathematical constants", ->{
    assert(Math.PI, 3.14159265358979323846)
    assert(Math.E, 2.7182818284590451)
    assert(Math.LOG2, 0.69314718055994529)
    assert(Math.LOG10, 2.3025850929940459)
  })

  it("calculates roots via cbrt", ->{
    assert(Math.cbrt(2).close_to(1.2599210499, 0.0000001), true)
    assert(Math.cbrt(20).close_to(2.7144176166, 0.0000001), true)
    assert(Math.cbrt(500).close_to(7.9370052598, 0.0000001), true)
    assert(Math.cbrt(9).close_to(2.0800838231, 0.0000001), true)
    assert(Math.cbrt(-90).close_to(-4.4814047466, 0.0000001), true)
  })

  it("calculates roots via sqrt", ->{
    assert(Math.sqrt(2).close_to(1.4142135624, 0.0000001), true)
    assert(Math.sqrt(20).close_to(4.472135955, 0.0000001), true)
    assert(Math.sqrt(500).close_to(22.360679775, 0.0000001), true)
    assert(Math.sqrt(9).close_to(3, 0.0000001), true)
    assert(Math.sqrt(-90).to_s(), "NAN")
  })

  it("gets the log", ->{
    assert(Math.log(10).close_to(2.3025850929940459, 0.0000001), true)
    assert(Math.log(100).close_to(4.6051701859880918, 0.0000001), true)
    assert(Math.log(500).close_to(6.2146080984221914, 0.0000001), true)
    assert(Math.log(892.5).close_to(6.7940265136537938, 0.0000001), true)
    assert(Math.log(-90).to_s(), "NAN")
  })

  it("trigonometric functions", ->{
    assert(Math.cos(2).close_to(-0.4161468365, 0.0000001), true)
    assert(Math.cos(20).close_to(0.4080820618, 0.0000001), true)
    assert(Math.cos(-90).close_to(-0.4480736161, 0.0000001), true)

    assert(Math.sin(2).close_to(0.9092974268, 0.0000001), true)
    assert(Math.sin(20).close_to(0.9129452507, 0.0000001), true)
    assert(Math.sin(-90).close_to(-0.8939966636, 0.0000001), true)

    assert(Math.tan(2).close_to(-2.1850398633, 0.0000001), true)
    assert(Math.tan(20).close_to(2.2371609442, 0.0000001), true)
    assert(Math.tan(-90).close_to(1.9952004122, 0.0000001), true)
  })

  it("inverse trigonometric functions", ->{
    assert(Math.acos(-0.5).close_to(2.0943951023931957, 0.0000001), true)
    assert(Math.acos(0.2).close_to(1.3694384060045657, 0.0000001), true)
    assert(Math.acos(0.892).close_to(0.4690458582650856, 0.0000001), true)

    assert(Math.asin(-0.5).close_to(-0.52359877559829882, 0.0000001), true)
    assert(Math.asin(0.2).close_to(0.2013579207903308, 0.0000001), true)
    assert(Math.asin(0.892).close_to(1.101750468529811, 0.0000001), true)

    assert(Math.atan(-0.5).close_to(-0.46364760900080615, 0.0000001), true)
    assert(Math.atan(0.2).close_to(0.19739555984988078, 0.0000001), true)
    assert(Math.atan(0.892).close_to(0.72837758931190089, 0.0000001), true)
  })

  it("hyperbolic functions", ->{
    assert(Math.cosh(-0.5).close_to(1.1276259652063807, 0.0000001), true)
    assert(Math.cosh(0.2).close_to(1.0200667556190759, 0.0000001), true)
    assert(Math.cosh(0.892).close_to(1.4249200230556498, 0.0000001), true)

    assert(Math.sinh(-0.5).close_to(-0.52109530549374738, 0.0000001), true)
    assert(Math.sinh(0.2).close_to(0.20133600254109399, 0.0000001), true)
    assert(Math.sinh(0.892).close_to(1.0150847610445708, 0.0000001), true)

    assert(Math.tanh(-0.5).close_to(-0.46211715726000974, 0.0000001), true)
    assert(Math.tanh(0.2).close_to(0.19737532022490401, 0.0000001), true)
    assert(Math.tanh(0.892).close_to(0.71238016493570389, 0.0000001), true)
  })

  it("inverse hyperbolic functions", ->{
    assert(Math.acosh(5).close_to(2.2924316695611777, 0.0000001), true)
    assert(Math.acosh(28).close_to(4.0250326605516182, 0.0000001), true)
    assert(Math.acosh(500).close_to(6.9077542789806374, 0.0000001), true)

    assert(Math.asinh(-0.5).close_to(-0.48121182505960342, 0.0000001), true)
    assert(Math.asinh(0.2).close_to(0.19869011034924142, 0.0000001), true)
    assert(Math.asinh(0.892).close_to(0.80290874355870534, 0.0000001), true)

    assert(Math.atanh(-0.5).close_to(-0.54930614433405489, 0.0000001), true)
    assert(Math.atanh(0.2).close_to(0.20273255405408219, 0.0000001), true)
    assert(Math.atanh(0.892).close_to(1.431629261243802, 0.0000001), true)
  })


  it("ceil & floor", ->{
    assert(Math.ceil(2.5).close_to(3, 0), true)
    assert(Math.ceil(20).close_to(20, 0), true)
    assert(Math.ceil(0.000000001).close_to(1, 0), true)
    assert(Math.ceil(9.01).close_to(10, 0), true)
    assert(Math.ceil(-90).close_to(-90, 0), true)

    assert(Math.floor(2.5).close_to(2, 0), true)
    assert(Math.floor(20).close_to(20, 0), true)
    assert(Math.floor(0.00000001).close_to(0, 0), true)
    assert(Math.floor(9.01).close_to(9, 0), true)
    assert(Math.floor(-90).close_to(-90, 0), true)
  })

}
