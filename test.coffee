{Opt, Rep, Grammar} = require 'parsing/grammar'
Parser = require 'parsing/parser'
Generator = require 'parsing/generator'

grammar = new Grammar
grammar.define ->
    # # Currently broken as Rep will insert grammer.between between repetions
    # # which doesn't interact nicely if the rule is used by grammar.between.
    # @whitespace.add Rep @whitespace_character
    @whitespace.add @whitespace_character
    @whitespace_character.add ' '
    @whitespace_character.add '\t'

    # Whitespace is optional between anything
    grammar.between.add Opt @whitespace

    grammar.root.add @statement_list

    @statement_list.add Opt Rep(@statement, separator: ';')

    @body.add ['{', @statement_list, '}']
    @condition.add ['(', @expression, ')']

    @statement.add @if
    @if.add ['if', @condition, @body]

    @variable.add 'variable'

    @expression.add @variable
    @expression.add [@expression, '+', @variable]
    @expression.add [@expression, '-', @variable]

parser = new Parser grammar
parser.parse ''
parser.parse 'if(variable){}'
parser.parse 'if(variable+variable){}'
parser.parse 'if ( variable ){}'
parser.parse 'if ( variable ){}'
parser.parse 'if ( variable - variable+variable -variable- variable){};if(variable){}'

generator = new Generator grammar
console.log generator.generate()
console.log generator.generate()
console.log generator.generate()
console.log generator.generate()
console.log generator.generate()
console.log generator.generate()

# Generator does not properly take into account grammar.between
# [ 'if(variable-variable-variable+variable){if(variable){};if(variable+variable-variable-variable){}};if(variable){}' ]
# []
# []
# []
# [ 'if(variable-variable){}' ]
# [ 'if(variable-variable){};if(variable+variable-variable+variable+variable-variable){if(variable+variable-variable){}};if(variable-variable){}' ]
