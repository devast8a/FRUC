nearley = require 'nearley'

module.exports =
class Parser
    constructor: (@grammar)->

    parse: (input)->
        parser = new nearley.Parser @grammar.ParserRules, @grammar.ParserStart
        parser.feed input

        if parser.results.length != 1
            throw new Error

        return parser.results[0]
