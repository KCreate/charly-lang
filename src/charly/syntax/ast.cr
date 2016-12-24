require "../helper.cr"
require "./token.cr"
require "./location.cr"
require "../interpreter/types.cr"

module Charly::AST

  # Returns true if a given node represents a primitive value
  #
  # ```
  # AST.is_primitive(IfStatement.new) # => false
  # AST.is_primitive(NumericLiteral.new) # => true
  # ```
  def self.is_primitive(node : ASTNode)
    node.is_a?(NumericLiteral) ||
    node.is_a?(StringLiteral) ||
    node.is_a?(BooleanLiteral) ||
    node.is_a?(NullLiteral) ||
    node.is_a?(NANLiteral) ||
    node.is_a?(PrecalculatedValue)
  end

  # The `AST` is the result of the parsing step, holding all variable names
  # function declarations and language constructs.
  abstract class ASTNode
    property children : Array(ASTNode)

    property! location_start : Location?
    property! location_end : Location?

    def initialize(@children = [] of ASTNode)
    end

    # Set the location_start and location_end values to *location_start*
    def at(@location_start)
      @location_end = location_start
      self
    end

    # Set the location_start and location_end values
    def at(@location_start, @location_end)
      self
    end

    # Set the location_start and location_end values to these of *node*
    def at(node : ASTNode)
      at(node.location_start, node.location_end)
    end

    # Set the location to the start of *left* and the end of *right*
    def at(left : ASTNode, right : ASTNode)
      at(left.location_start, right.location_end)
    end

    delegate "<<", to: @children
    delegate "[]", to: @children
    delegate "[]=", to: @children
    delegate "[]?", to: @children
    delegate "each", to: @children
    delegate "each_with_index", to: @children
    delegate "size", to: @children

    # :nodoc:
    def to_s(io)
      io << "#{self.class.name.split("::").last}"

      if (meta = info).size > 0
        io << " | #{meta}"
      end
      io << "\n"

      children.each do |child|
        lines = child.to_s.each_line.each
        lines.each do |line|
          if !['┣', '┃'].includes?(line[0])
            io << line.indent(1, "┣╸")
          elsif line.size > 0
            io << line.indent(1, "┃ ")
          end

          io << "\n"
        end
      end
    end

    # :nodoc:
    def inspect(io)
      io << self.class.name.split("::").last
      io << ":"
      io << @children.size
    end

    # :nodoc:
    def info
      ""
    end
  end

  # Helper macro to describe ASTNodes in a nice and clean way
  macro ast_node(name, *properties)
    class {{name.id}} < ASTNode
      {% for property in properties %}
        {% if property.is_a?(Assign) %}
          property {{property.target.id}}
        {% elsif property.is_a?(TypeDeclaration) %}
          property {{property.var}} : {{property.type}}
        {% else %}
          property :{{property.id}}
        {% end %}
      {% end %}

      {% if properties.size == 0 %}
        def initialize(@children = [] of ASTNode)
        end
      {% else %}
        def initialize({{
                         *properties.map do |field|
                           "@#{field.id}".id
                         end
                       }})
          arg = [{{
                   *properties.map do |field|
                     field.var
                   end
                 }}] of ASTNode | TokenType | String | Nil | BaseType

          tmp_children = [] of ASTNode

          arg.each do |field|
            tmp_children << field if field.is_a? ASTNode
          end

          @children = tmp_children
        end
      {% end %}

      {{yield}}
    end
  end

  ast_node PrecalculatedValue,
    value : BaseType do
    def info
      "#{@value}"
    end
  end

  ast_node Empty
  ast_node Block

  ast_node IfStatement,
    test : ASTNode,
    consequent : Block,
    alternate : ASTNode?

  ast_node GuardStatement,
    test : ASTNode,
    alternate : Block

  ast_node UnlessStatement,
    test : ASTNode,
    consequent : Block,
    alternate : Block?

  ast_node WhileStatement,
    test : ASTNode,
    consequent : Block

  ast_node UntilStatement,
    test : ASTNode,
    consequent : Block

  ast_node LoopStatement,
    consequent : Block

  ast_node Expression

  ast_node UnaryExpression,
    operator : TokenType,
    right : ASTNode do
    def info
      "#{@operator}"
    end
  end

  ast_node BinaryExpression,
    operator : TokenType,
    left : ASTNode,
    right : ASTNode do
    def info
      "#{@operator}"
    end
  end

  ast_node ComparisonExpression,
    operator : TokenType,
    left : ASTNode,
    right : ASTNode do
    def info
      "#{@operator}"
    end
  end

  ast_node And,
    left : ASTNode,
    right : ASTNode

  ast_node Or,
    left : ASTNode,
    right : ASTNode

  ast_node VariableInitialisation,
    identifier : IdentifierLiteral,
    expression : ASTNode

  ast_node VariableAssignment,
    identifier : ASTNode,
    expression : ASTNode

  ast_node ConstantInitialisation,
    identifier : IdentifierLiteral,
    expression : ASTNode

  ast_node CallExpression,
    identifier : ASTNode,
    argumentlist : ExpressionList

  ast_node MemberExpression,
    identifier : ASTNode,
    member : IdentifierLiteral

  ast_node IndexExpression,
    identifier : ASTNode,
    argument : ASTNode

  ast_node ExpressionList
  ast_node IdentifierList do
    def initialize(children : Array(IdentifierLiteral))
      @children = [] of ASTNode
      children.each do |child|
        @children << child
      end
    end
  end

  ast_node ReturnStatement,
    expression : ASTNode

  ast_node ThrowStatement,
    expression : ASTNode

  ast_node BreakStatement

  ast_node TryCatchStatement,
    try_block : Block,
    exception_name : IdentifierLiteral,
    catch_block : Block

  ast_node NullLiteral
  ast_node NANLiteral
  ast_node IdentifierLiteral,
    name : String do
    def initialize(@name : String)
      @children = [] of ASTNode
    end

    def info
      "#{@name}"
    end
  end

  ast_node ReferenceIdentifier,
    identifier : IdentifierLiteral

  ast_node StringLiteral,
    value : String do
    def initialize(@value : String)
      @children = [] of ASTNode
    end

    def info
      "#{@value}"
    end
  end

  ast_node NumericLiteral,
    value : Float64 do
    def initialize(@value : Float64)
      @children = [] of ASTNode
    end

    def info
      "#{@value}"
    end
  end

  ast_node KeywordLiteral,
    name : String do
    def initialize(@name : String)
      @children = [] of ASTNode
    end

    def info
      "#{@name}"
    end
  end

  ast_node BooleanLiteral,
    value : Bool do
    def initialize(@value : Bool)
      @children = [] of ASTNode
    end

    def info
      "#{@value}"
    end
  end

  ast_node ArrayLiteral

  ast_node FunctionLiteral,
    name : String,
    argumentlist : IdentifierList,
    block : Block

  ast_node ContainerLiteral,
    block : Block

  ast_node ClassLiteral,
    name : String,
    block : Block,
    parents : IdentifierList

  ast_node PrimitiveClassLiteral,
    name : String,
    block : Block

  ast_node PropertyDeclaration,
    identifier : IdentifierLiteral

  ast_node StaticDeclaration,
    node : ASTNode

  ast_node LeftParenLiteral
  ast_node RightParenLiteral
  ast_node LeftCurlyLiteral
  ast_node RightCurlyLiteral
  ast_node LeftBracketLiteral
  ast_node RightBracketLiteral

  # Punctuators
  ast_node SemicolonLiteral
  ast_node CommaLiteral
  ast_node PointLiteral
end
