require "./spec_helper.cr"
include Charly

describe Container do

  it "Correctly creates a new container" do
    myContainer = Container(Int32).new

    myContainer["a", Flag::INIT] = 25
    myContainer["b", Flag::INIT] = 50
    myContainer["c", Flag::INIT] = 75
    myContainer["a"] = 100

    myContainer["a"].should eq 100
    myContainer["b"].should eq 50
    myContainer["c"].should eq 75
  end

  it "Correctly creates a new nested container" do
    parent = Container(Int32).new
    child = Container(Int32).new(parent)
    parent["var", Flag::INIT] = 25
    child["var"].should eq 25
    child["var"] = 100
    parent["var"].should eq 100
  end

  it "Creates constants" do
    c = Container(Float64).new

    c["PI", Flag::CONSTANT | Flag::INIT] = 3.14

    expect_raises(ContainerReferenceError) do
      c["PI"] = 4.14
    end
  end

  it "Overwrites constants" do
    c = Container(Int32).new

    c["a", Flag::CONSTANT | Flag::INIT] = 25
    c["a", Flag::OVERWRITE_CONSTANT] = 50

    c["a"].should eq 50
  end

  it "Stores multiple data types" do
    c = Container(Int32 | String | Bool).new

    c["myNum", Flag::INIT] = 25
    c["myString", Flag::INIT] = "hello"
    c["myBool", Flag::INIT] = true

    c["myNum"].should eq 25
    c["myString"].should eq "hello"
    c["myBool"].should eq true
  end

  it "Ignores parents" do
    parent = Container(Int32).new
    child = Container(Int32).new(parent)

    parent["a", Flag::INIT] = 25

    expect_raises(ContainerReferenceError) do
      child["a", Flag::IGNORE_PARENT]
    end
  end

  it "Creates new variables inside children" do
    parent = Container(Int32).new
    child = Container(Int32).new(parent)

    parent["a", Flag::INIT] = 25
    child["a", Flag::INIT] = 50

    parent["a"].should eq 25

    parent["a"] = 75

    child["a"].should eq 50

    child["a"] = 100

    parent["a"].should eq 75
    child["a"].should eq 100
  end

  it "Can redeclare constants inside children" do
    parent = Container(Int32).new
    child = Container(Int32).new(parent)

    parent["myConst", Flag::INIT | Flag::CONSTANT] = 200
    child["myConst", Flag::INIT | Flag::CONSTANT] = 300

    parent["myConst"].should eq 200
    child["myConst"].should eq 300
  end

end
