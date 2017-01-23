require "../helper.cr"
require "./token.cr"
require "./location.cr"
require "../interpreter/types.cr"
require "../visitors/TreeVisitor.cr"

module Charly::AST
  # Returns true if a given node represents a primitive value
  #
  # ```
  # AST.is_primitive(IfStatement.new)    # => false
  # AST.is_primitive(NumericLiteral.new) # => true
  # ```
  def self.is_primitive(node : ASTNode)
    node.is_a?(NumericLiteral) ||
      node.is_a?(StringLiteral) ||
      node.is_a?(BooleanLiteral) ||
      node.is_a?(NullLiteral) ||
      node.is_a?(NANLiteral)
  end

  # The `AST` is the result of the parsing step, holding all variable names
  # function declarations and language constructs.
  abstract class ASTNode
    property! location_start : Location?
    property! location_end : Location?

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

    def accept(visitor : TreeVisitor, io : IO)
      visitor.visit self, io
    end

    # :nodoc:
    def inspect(io)
      io << self.class.name.split("::").last
    end

    @[AlwaysInline]
    def children
      vars = {{ @type.instance_vars }}
      node_vars = [] of ASTNode
      vars.each do |node|
        if node.is_a? ASTNode
          node_vars << node
        end
      end
      node_vars
    end
  end

  # Helper macro to describe ASTNodes in a nice and clean way
  macro ast_node(name, *properties)
    class {{name.id}} < ASTNode
      {% for property in properties %}
        property {{property.var}} : {{property.type}}
      {% end %}

      def initialize({{
                       *properties.map do |field|
                         "@#{field.id}".id
                       end
                     }})
      end
    end
  end

  ast_node Empty
  ast_node Block,
    children : Array(ASTNode)

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

  ast_node UnaryExpression,
    operator : TokenType,
    right : ASTNode

  ast_node BinaryExpression,
    operator : TokenType,
    left : ASTNode,
    right : ASTNode

  ast_node ComparisonExpression,
    operator : TokenType,
    left : ASTNode,
    right : ASTNode

  ast_node SwitchStatement,
    test : ASTNode,
    body : SwitchNodeList,
    default_block : Block?

  ast_node SwitchNodeList,
    children : Array(SwitchNode)

  ast_node SwitchNode,
    values : ExpressionList,
    block : Block

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

  ast_node ExpressionList,
    children : Array(ASTNode)

  ast_node IdentifierList,
    children : Array(ASTNode)

  ast_node ReturnStatement,
    expression : ASTNode

  ast_node ThrowStatement,
    expression : ASTNode

  ast_node BreakStatement

  ast_node ContinueStatement

  ast_node TryCatchStatement,
    try_block : Block,
    exception_name : IdentifierLiteral,
    catch_block : Block

  ast_node NullLiteral
  ast_node NANLiteral
  ast_node IdentifierLiteral,
    name : String

  ast_node StringLiteral,
    value : String

  ast_node NumericLiteral,
    value : Float64

  ast_node KeywordLiteral,
    name : String

  ast_node BooleanLiteral,
    value : Bool

  ast_node ArrayLiteral,
    children : Array(ASTNode)

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

  ast_node TypeofExpression,
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
