require "./types.cr"

module Charly
  class Calculator
    # Visit a regular operation
    def self.visit(operator : TokenType, left : BaseType, right : BaseType)
      case operator

      # Arithmetic operators
      when TokenType::Plus
        return add left, right
      when TokenType::Minus
        return sub left, right
      when TokenType::Mult
        return mul left, right
      when TokenType::Divd
        return div left, right
      when TokenType::Mod
        return mod left, right
      when TokenType::Pow
        return pow left, right

      # Comparison operators
      when TokenType::Less
        return lt left, right
      when TokenType::Greater
        return gt left, right
      when TokenType::LessEqual
        return le left, right
      when TokenType::GreaterEqual
        return ge left, right
      when TokenType::Equal
        return eq left, right
      when TokenType::Not
        return ne left, right

      # Bitwise operators
      when TokenType::BitOR
        return or left, right
      when TokenType::BitXOR
        return xor left, right
      when TokenType::BitAND
        return and left, right
      when TokenType::LeftShift
        return lshift left, right
      when TokenType::RightShift
        return rshift left, right
      end

      return TNumeric.new(Float64::NAN)
    end

    # Unary Operations
    def self.visit_unary(operator : TokenType, right : BaseType)
      case operator
      when TokenType::Plus
        return uadd right
      when TokenType::Minus
        return usub right
      when TokenType::Not
        return une right
      when TokenType::BitNOT
        return not right
      end

      return TNumeric.new(Float64::NAN)
    end

    # Addition
    def self.add(left : BaseType, right : BaseType)
      if left.is_a?(TNumeric) && right.is_a?(TNumeric)
        return TNumeric.new(left.value + right.value)
      end

      if left.is_a?(TString) || right.is_a?(TString)
        return TString.new("#{left}#{right}")
      end

      return TNumeric.new(Float64::NAN)
    end

    # Subtraction
    def self.sub(left : BaseType, right : BaseType)
      if left.is_a?(TNumeric) && right.is_a?(TNumeric)
        return TNumeric.new(left.value - right.value)
      end

      return TNumeric.new(Float64::NAN)
    end

    # Multiplication
    def self.mul(left : BaseType, right : BaseType)
      if left.is_a?(TNumeric) && right.is_a?(TNumeric)
        if left.value == 0 || right.value == 0
          return TNumeric.new(0)
        end
        return TNumeric.new(left.value * right.value)
      end

      if left.is_a?(TString) && right.is_a?(TNumeric)
        return TString.new(left.value * right.value.to_i64)
      end

      if left.is_a?(TNumeric) && right.is_a?(TString)
        return TString.new(right.value * left.value.to_i64)
      end

      return TNumeric.new(Float64::NAN)
    end

    # Division
    def self.div(left : BaseType, right : BaseType)
      if left.is_a?(TNumeric) && right.is_a?(TNumeric)
        if left.value != 0 && right.value != 0
          return TNumeric.new(left.value / right.value)
        end
      end

      return TNumeric.new(Float64::NAN)
    end

    # Modulus
    def self.mod(left : BaseType, right : BaseType)
      if left.is_a?(TNumeric) && right.is_a?(TNumeric)
        if right.value == 0
          return TNumeric.new(Float64::NAN)
        end
        return TNumeric.new(left.value.to_i64 % right.value.to_i64)
      end

      return TNumeric.new(Float64::NAN)
    end

    # Exponentation
    def self.pow(left : BaseType, right : BaseType)
      if left.is_a?(TNumeric) && right.is_a?(TNumeric)
        return TNumeric.new(left.value ** right.value)
      end

      return TNumeric.new(Float64::NAN)
    end

    # Less than
    def self.lt(left : BaseType, right : BaseType)
      if left.is_a?(TNumeric) && right.is_a?(TNumeric)
        return TBoolean.new(left.value < right.value)
      end

      if left.is_a?(TString) && right.is_a?(TString)
        return TBoolean.new(left.value.size < right.value.size)
      end

      return TBoolean.new(false)
    end

    # Greater than
    def self.gt(left : BaseType, right : BaseType)
      if left.is_a?(TNumeric) && right.is_a?(TNumeric)
        return TBoolean.new(left.value > right.value)
      end

      if left.is_a?(TString) && right.is_a?(TString)
        return TBoolean.new(left.value.size > right.value.size)
      end

      return TBoolean.new(false)
    end

    # Less equal
    def self.le(left : BaseType, right : BaseType)
      if left.is_a?(TNumeric) && right.is_a?(TNumeric)
        return TBoolean.new(left.value <= right.value)
      end

      if left.is_a?(TString) && right.is_a?(TString)
        return TBoolean.new(left.value.size <= right.value.size)
      end

      return TBoolean.new(false)
    end

    # Greater equal
    def self.ge(left : BaseType, right : BaseType)
      if left.is_a?(TNumeric) && right.is_a?(TNumeric)
        return TBoolean.new(left.value >= right.value)
      end

      if left.is_a?(TString) && right.is_a?(TString)
        return TBoolean.new(left.value.size >= right.value.size)
      end

      return TBoolean.new(false)
    end

    # Equal
    def self.eq(left : BaseType, right : BaseType)
      if left.is_a?(TNumeric) && right.is_a?(TNumeric)
        if left.value.nan? && right.value.nan?
          return TBoolean.new true
        end

        return TBoolean.new(left.value == right.value)
      end

      if left.is_a?(TBoolean) && right.is_a?(TBoolean)
        return TBoolean.new(left.value == right.value)
      end

      if left.is_a?(TString) && right.is_a?(TString)
        return TBoolean.new(left.value == right.value)
      end

      if left.is_a?(TFunc) && right.is_a?(TFunc)
        return TBoolean.new(left == right)
      end

      if left.is_a?(TClass) && right.is_a?(TClass)
        return TBoolean.new(left == right)
      end

      if left.is_a?(TPrimitiveClass) && right.is_a?(TPrimitiveClass)
        return TBoolean.new(left == right)
      end

      if left.is_a?(TObject) && right.is_a?(TObject)
        return TBoolean.new(left == right)
      end

      if left.is_a?(TNull)
        return TBoolean.new(right.is_a?(TNull))
      end

      if right.is_a?(TNull)
        return TBoolean.new(left.is_a?(TNull))
      end

      return TBoolean.new(false)
    end

    # Not equal
    def self.ne(left : BaseType, right : BaseType)
      if left.is_a?(TNumeric) && right.is_a?(TNumeric)
        return TBoolean.new(left.value != right.value)
      end

      if left.is_a?(TBoolean) && right.is_a?(TBoolean)
        return TBoolean.new(left.value != right.value)
      end

      if left.is_a?(TString) && right.is_a?(TString)
        return TBoolean.new(left.value != right.value)
      end

      if left.is_a?(TFunc) && right.is_a?(TFunc)
        return TBoolean.new(left != right)
      end

      if left.is_a?(TClass) && right.is_a?(TClass)
        return TBoolean.new(left != right)
      end

      if left.is_a?(TPrimitiveClass) && right.is_a?(TPrimitiveClass)
        return TBoolean.new(left != right)
      end

      if left.is_a?(TObject) && right.is_a?(TObject)
        return TBoolean.new(left != right)
      end

      if left.is_a?(TNull)
        return TBoolean.new(!right.is_a?(TNull))
      end

      if right.is_a?(TNull)
        return TBoolean.new(!left.is_a?(TNull))
      end

      return TBoolean.new(false)
    end

    # Unary not equal
    def self.une(right : BaseType)
      TBoolean.new !truthyness right
    end

    # Unary subtraction
    def self.usub(right : BaseType)
      if right.is_a? TNumeric
        return TNumeric.new(-right.value)
      end

      return TNumeric.new(Float64::NAN)
    end

    # Unary addition
    def self.uadd(right : BaseType)
      right
    end

    # Bitwise AND
    def self.and(left : BaseType, right : BaseType)
      unless left.is_a?(TNumeric) && right.is_a?(TNumeric)
        return TNumeric.new Float64::NAN
      end

      left, right = left.value.to_i64, right.value.to_i64
      return TNumeric.new left & right
    end

    # Bitwise OR
    def self.or(left : BaseType, right : BaseType)
      unless left.is_a?(TNumeric) && right.is_a?(TNumeric)
        return TNumeric.new Float64::NAN
      end

      left, right = left.value.to_i64, right.value.to_i64
      return TNumeric.new left | right
    end

    # Bitwise XOR
    def self.xor(left : BaseType, right : BaseType)
      unless left.is_a?(TNumeric) && right.is_a?(TNumeric)
        return TNumeric.new Float64::NAN
      end

      left, right = left.value.to_i64, right.value.to_i64
      return TNumeric.new left ^ right
    end

    # Bitwise Left shift
    def self.lshift(left : BaseType, right : BaseType)

      unless left.is_a?(TNumeric)

        if left.is_a? TArray
          left.value << right
          return left
        end

        return TNumeric.new Float64::NAN
      end

      unless right.is_a? TNumeric
        return TNumeric.new Float64::NAN
      end

      left, right = left.value.to_i64, right.value.to_i64
      return TNumeric.new left << right
    end

    # Bitwise right shift
    def self.rshift(left : BaseType, right : BaseType)
      unless left.is_a?(TNumeric) && right.is_a?(TNumeric)
        return TNumeric.new Float64::NAN
      end

      left, right = left.value.to_i64, right.value.to_i64
      return TNumeric.new left >> right
    end

    # Bitwise NOT
    def self.not(right : BaseType)
      unless right.is_a? TNumeric
        return TNumeric.new Float64::NAN
      end

      right = right.value.to_i64
      return TNumeric.new ~right
    end

    # Get the truthyness of a value
    def self.truthyness(value : BaseType)
      case value
      when .is_a? TBoolean
        return value.value
      when .is_a? TNull
        return false
      else
        return true
      end
    end
  end
end
