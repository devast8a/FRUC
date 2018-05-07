nearley = require 'nearley'

IndentationStream = require './streams/indentation'
Joiner = require './streams/joiner'

Fmt = require 'fmt'
fmt = new Fmt
    filterByKey: Fmt.reject ['metadata', 'map']

class NearleyParser extends nearley.Parser
    feed: (input)->
        if input instanceof Array
            for element in input
                if typeof(element) == 'string'
                    super element
                else
                    super [element]
        else
            if typeof(input) == 'string'
                super input
            else
                super [input]

    end: ->

module.exports =
class Parser
    constructor: (@grammar)->

    parse: (input)->
        map = []
        regex = /(?:\r\n|\r|\n)/g
        line = 0

        prev = 0
        while match = regex.exec input
            map.push
                start: prev
                end:   prev = regex.lastIndex
                line:  line++
                data:  match[0]

            prev += 1
        map.push {start: prev, end: input.length + 1, line: line++}

        parser = new NearleyParser @grammar.ParserRules, @grammar.ParserStart
        if @grammar.disable_indent
            stream = parser
        else
            stream = new IndentationStream new Joiner parser

        stream.feed input
        stream.end()
        
        results = parser.results.map (ast)->
            ast = ast[0].preprocess ast[1], ast[2], map
            ast.map = map
            return ast

        if results.length != 1
            for result in results
                console.log fmt.format result
            throw new Error "Expecting 1 parser result, got #{parser.results.length}"

        return results[0]
