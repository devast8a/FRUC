nearley = require 'nearley'
AstNode = require './grammar/astnode'

Fmt = require 'fmt'
fmt = new Fmt
    filterByKey: Fmt.reject ['metadata', 'map']

module.exports =
class Parser
    constructor: (@grammar)->

    parse: (input)->
        map = []
        regex = /(\r\n|\r|\n)/g
        line = 0

        prev = 0
        while match = regex.exec input
            index = regex.lastIndex - match[0].length
            map.push {start: prev, end: index, line: line++}
            prev = regex.lastIndex
        map.push {start: prev, end: input.length + 1, line: line++}

        parser = new nearley.Parser @grammar.ParserRules, @grammar.ParserStart
        
        if input instanceof Array
            for p in input
                if typeof(p) == 'string'
                    parser.feed p
                else
                    parser.feed [p]
        else
            parser.feed input

        results = parser.results.map (ast)->
            ast = ast[0].preprocess ast[1], ast[2], map
            ast.map = map
            return ast

        if results.length != 1
            for result in results
                console.log fmt.format result
            throw new Error "#{parser.results.length}"

        return results[0]
