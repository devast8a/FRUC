Grammar = require 'parsing/grammar'
{Rep, Opt, OptRep} = require 'parsing/grammar_helpers'

grammar = new Grammar
grammar.define ->
    NS = ''
    _ = ' '

    @atom.add @identifier
    @identifier.add /[a-zA-Z_][a-zA-Z_0-9]*/

    ############################################################################
    # Atoms
    ############################################################################
    #@expression.add @atom
    @atom.add ['(', @expression, ')']

    # Bracket index
    @atom.add @bracket_index

    @bracket_index.add [@atom, NS, '[', @bracket_index_expressions, ']']
    @bracket_index_expressions.add Rep(@bracket_index_expression, separator: ',')
    @bracket_index_expression.add @expression


    # Dot index
    @atom.add @dot_index

    @dot_index.add [@atom, '.', @identifier]

    ############################################################################
    # Expressions
    ############################################################################
    # Binary Expression
    @expression.add @binary_expression
    @binary_expression.add @prefix_postfix
    @binary_expression.add [@binary_expression, _, @binary_operator, _, @prefix_postfix]

    @binary_operator.add /[~!@#$%^&*\-+_=]+/

    # Allows only one of prefix or postfix to be used
    @prefix_postfix.add @prefix_expression
    @prefix_postfix.add @postfix_expression
    @prefix_postfix.add @atom

    # Prefix Expression
    @prefix_expression.add [@prefix_operator, NS, @atom]
    @prefix_operator.add /[~!@#$%^&*\-+_=]+/

    # Postfix Expression
    @postfix_expression.add [@atom, NS, @postfix_operator]
    @postfix_operator.add /[~!@#$%^&*\-+_=]+/

    grammar.root.add @expression



Parser = require 'parsing/parser'
parser = new Parser grammar
parser.parse '++abc + abc++'
parser.parse 'abc++ + ++abc'
parser.parse '++(abc++)'


Generator = require 'parsing/generator'
generator = new Generator grammar
console.log generator.generate()
