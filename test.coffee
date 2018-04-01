Grammar = require 'parsing/grammar'
{Rep, Opt, OptRep, Token, importSpace} = require 'parsing/grammar_helpers'

grammar = new Grammar
grammar.define ->
    # SPACE, NO_SPACE, or SPACE_NL are /explicit/ (and match repeated whitespace)
    # eg.
    #   ['a', 'b'] could match 'ab' or 'a b'
    #   ['a', SPACE, 'b'] matches 'a b' but NOT 'ab'
    #   ['a', NO_SPACE, 'b'] matches 'ab' but NOT 'a b'
    {SPACE, NO_SPACE, SPACE_NL} = importSpace grammar
    # Sets up optional whitespace between all matched input
    grammar.between.add Opt(SPACE_NL)

    ############################################################################
    # Identifiers
    @identifier.add /[a-zA-Z_][a-zA-Z_0-9]*/

    ############################################################################
    # Function declaration
    @statement.add @function
    @function.add ['def', SPACE, @identifier, Opt(@function_parameters), '->', @function_body]

    @function_parameters.add ['(', OptRep(@function_parameter, separator: ','), ')']
    @function_parameter.add @identifier

    @function_body.add @body

    ############################################################################
    # Variable declaration
    @statement.add @declare_variable
    @declare_variable.add [@identifier, ':', @identifier]

    ############################################################################
    # Function call
    @statement.add @call

    @call.add [@callable, NO_SPACE, '(', Opt(@call_arguments), ')']

    # Arguments
    @call_arguments.add @call_argument, separator: ','
    @call_argument.add @expression

    # Callables
    @callable.add @identifier


    @expression.add @identifier
    @body.add ['{', @statement_list, '}']
    @statement_list.add Rep(@statement)

    grammar.root.add @statement_list












Fmt = require 'fmt'
fmt = new Fmt

Parser = require 'parsing/parser'
parser = new Parser grammar

output = """
def main -> {
    print(hello)
}
"""

console.time 'parsing'
parser.parse output
console.timeEnd 'parsing'


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
