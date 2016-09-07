require_relative "../misc/Helper.rb"
require_relative "Parser.rb"
require_relative "AST.rb"

# Optimizes a program to be more efficient
# Doesn't always produce the "perfect" program
class Optimizer

  def initialize
    @finished = false
  end

  # Optimize a program
  def optimize_program(program)
    if !program.is Program
      raise "Not a Program instance"
    end

    dlog "- Optimizing program structure"
    while !@finished
      @finished = true
      optimize :structure, program
    end

    # Reset @finished
    @finished = false

    dlog "- Generating abstract syntax tree groupings"
    while !@finished
      @finished = true
      optimize :group, program, true
    end

    program
  end

  # Optimize a node with a given flow
  # options are:
  # - structure
  # - group
  def optimize(flow, node, after = false)

    # Backup the parent
    parent_save = node.parent

    # Call the entry handler
    unless after
      case flow
      when :structure
        node = flow_structure node
      when :group
        node = flow_group node
      end

      # Return if the node returned NIL
      if node == NIL
        return NIL
      end

      # Correct the parent pointer
      node.parent = parent_save
    end


    # Optimize all children and remove nil values afterwards
    node.children.collect! do |child|
      case flow
      when :structure
        optimize :structure, child, after
      when :group
        optimize :group, child, after
      end
    end
    node.children = node.children.compact

    # Call the leave handler
    if after
      case flow
      when :structure
        node = flow_structure node
      when :group
        node = flow_group node
      end

      # Return if the node returned NIL
      if node == NIL
        return NIL
      end

      # Correct the parent pointer
      node.parent = parent_save
    end

    node
  end

  # Optimize the structure of a node
  def flow_structure(node)

    # NumericLiterals value property should be an actual INT
    if node.is(NumericLiteral) && node.value.is_a?(String)
      node.value = node.value.to_f
      @finished = false
      return node
    end

    # Expressions that only contain 1 other expression
    # should be replaced by that expression
    if node.is(Expression) && node.children.length == 1
      if node.children[0].is(Expression)
        @finished = false
        return node.children[0]
      end
    end

    # Expression that only contain terminal nodes
    # that can be treated as expressions
    # should be replaced by that nodes
    if node.is(Expression) && node.children.length == 1
      if node.children[0].is NumericLiteral, StringLiteral, IdentifierLiteral
        @finished = false
        return node.children[0]
      end
    end

    node
  end

  # Optimize the groupings of the node
  def flow_group(node)

    # Airthmetic expressions involving an operator


    node
  end
end
