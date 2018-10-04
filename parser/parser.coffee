nearley = require 'nearley'
{displayAst} = require '../analysis/ast_util'

IndentationStream = require './streams/indentation'
Joiner = require './streams/joiner'
Source = require '../common/source'

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
        map = Source.fromText input
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
                displayAst result
            throw new Error "Expecting 1 parser result, got #{parser.results.length}"

        return results[0]
