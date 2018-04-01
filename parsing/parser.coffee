nearley = require 'nearley'

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

        return parser.results[0]
