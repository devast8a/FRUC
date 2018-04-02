Grammar = require 'parsing/grammar'
{Rep, Opt, OptRep, Token, importSpace} = require 'parsing/grammar/helpers'

class Func
    constructor: (@name, @parameters, @body)->
class Call
    constructor: (@target, @args)->
class Quote
    constructor: (@ast)->
class Unquote
    constructor: (@ast)->
class Assignment
    constructor: (@target, @expression)->

grammar = new Grammar
grammar.define ->
    # SPACE, NO_SPACE, SPACE_NL are explicit
    #   ['a', 'b'] could match 'ab' or 'a b'
    #   ['a', SPACE, 'b'] matches 'a b' but NOT 'ab'
    #   ['a', NO_SPACE, 'b'] matches 'ab' but NOT 'a b'
    # They also match repeatedly
    #   ['a', 'b'] matches 'a        b'
    {SPACE, NO_SPACE, SPACE_NL} = importSpace grammar
    # Sets up optional whitespace between all matched input
    grammar.between.add Opt(SPACE_NL)

    ############################################################################
    # Identifiers
    @identifier.add /[a-zA-Z_][a-zA-Z_0-9]*/,
        (data)->
            # Output from regex is not nice to work with right now
            'identifier'

    ############################################################################
    # Function declaration
    @statement.add @function
    @function.add ['def', SPACE, @identifier, Opt(@function_parameters), '->', @function_body],
        ([name, parameters, body])->
            new Func name, parameters, body

    @function_parameters.add ['(', OptRep(@function_parameter, separator: ','), ')']
    @function_parameter.add @identifier

    @function_body.add @body

    ############################################################################
    # Function call
    @statement.add @call

    @call.add [@callable, NO_SPACE, '(', Opt(@call_arguments), ')'],
        ([callable, args])->
            new Call callable, args

    # Arguments
    @call_arguments.add Rep @call_argument, separator: ','
    @call_argument.add @expression

    # Callables
    @callable.add @identifier

    ############################################################################
    # Assignment
    @statement.add @assignment
    @assignment.add [@assignable, '=', @expression],
        ([assignable, expression])->
            new Assignment assignable, expression

    @assignable.add @identifier

    ############################################################################
    # Macros
    @expression.add @quote
    @quote.add ['-{', @expression, '}'], ->
        ([ast])->
            new Quote ast

    @expression.add @unquote
    @unquote.add ['+{', @expression, '}'], ->
        ([ast])->
            new Unquote ast

    ############################################################################
    # Expressions/bodies/etc...
    @expression.add @identifier
    @body.add ['{', @statement_list, '}']
    @statement_list.add Rep(@statement)

    # Disgusting ambiguous grammar
    @expression.add [@expression, '+', @expression]

    grammar.root.add @statement_list

Parser = require 'parsing/parser'
parser = new Parser grammar
console.time 'parsing'
parser.parse """
def main -> {
    expr = +{c + d}
    print(+{
        a + -{expr}
    })
    print(a + -{expr})
}
"""
# Assuming Quote/Unquote semantics from Metalua would be the same as
# define main -> {
#   print(ast("a + c + d"))
#   print(a + c + d)
console.timeEnd 'parsing'

# The generator still works
#Generator = require 'parsing/generator'
#generator = new Generator grammar
#
#for i in [1..10]
#    input = generator.generate()
#    if input.length > 0
#        console.log input
#        parser.parse input
#    else
#        console.log '<empty>'

# [ 'def\tq->\r\t {\rdef\tB(\tHl,mc,WT,yeI,R,c\r )->\r{\rqr(O)\t\n}\r}' ]
# [ 'XW(W\t )\r\n hPT(\r\r\t\t)' ]
# [ 'def z->\r\n\n{\r kx(\n\r)  \n}def L ()->{def\ts ->{\tdef\t \tUi8x(\r N,_S1YBk)->\r\r\t\r\n{\r\r\r\n\tdef  I\t->\r{def \t \tvvpMCQ->{  uuh()e(f \r)}QA(\n\t)}\r}}\n\t\n}\tVh(A \t)' ]
# [ 'def\tU\n()\n  \r->{\rdef  ms\n\t\t->\r\t {w4x()}}' ]
# [ 'def lD->\t\n\t\r\r{AbG0(S)Pk()\r \r def\tV\t()->\n{\r\r\t _()}\n a9()}' ]
# [ 'PpB(\r c\t)def  \tn->{\t E()\n}' ]
# [ '_()' ]
# [ 'bo()' ]
# [ 'W4I(\r\rJQ)' ]
# [ 'Ifpq(m\r\r\r )' ]
