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
            stack = [ast]

            while stack.length > 0
                top = stack[stack.length - 1]

                if top.dispatched
                    stack.pop()
                    top.parent.push top.definition.preprocess top, map
                else
                    top.definition.dispatch top, stack
                    top.dispatched = true

            return ast.parent[0]

        if results.length != 1
            for result in results
                displayAst result
            throw new Error "Expecting 1 parser result, got #{parser.results.length}"

        return results[0]
