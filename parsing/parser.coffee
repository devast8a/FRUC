nearley = require 'nearley'
AstNode = require './grammar/astnode'

module.exports =
class Parser
    constructor: (@grammar)->

    parse: (input)->
        parser = new nearley.Parser @grammar.ParserRules, @grammar.ParserStart
        
        if input instanceof Array
            for p in input
                if typeof(p) == 'string'
                    parser.feed p
                else
                    parser.feed [p]
        else
            parser.feed input

        if parser.results.length != 1
            console.log parser.results
            throw new Error "#{parser.results.length}"

        ast = parser.results[0]
        ast[0].preprocess ast[1], ast[2]
