Grammar = require 'parsing/grammar'
{Rep, Opt, OptRep, Token, importSpace} = require 'parsing/grammar/helpers'

class Identifier
    constructor: (@name)->

class DefineFunction
    constructor: (@name, @parameters, @body)->

class Body

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

    @identifier.add /[a-zA-Z_][a-zA-Z_0-9]*/,
        ->
            new Identifier 'regex still broken lel'

    
    ############################################################################
    # Function definition syntax
    @define_function.add ['def', SPACE, @identifier, Opt(@define_function_parameters), '->', @define_function_body],
        ([name, parameters, body])->
            new DefineFunction name, parameters, body

    # Parameters
    @define_function_parameters.add ['(', OptRep(@define_function_parameter, separator: ','), ')']
    @define_function_parameter.add @identifier

    # Body
    @define_function_body.add @body

    @body.add '{}',
        (data)->
            new Body

    grammar.root.add @define_function

Fmt = require 'fmt'
fmt = new Fmt

Parser = require 'parsing/parser'
parser = new Parser grammar
console.log fmt.format parser.parse """
def test -> {}
"""

#<DefineFunction>{
#    name: <Identifier>{
#        name: "regex still broken lel"
#        start: 4
#    }
#    parameters: [
#        start: 8
#    ]
#    body: <Body>{
#        start: 12
#    }
#    start: 0
#}
