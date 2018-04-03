nearley = require 'nearley'
AstNode = require './grammar/astnode'

process = ([matcher, nodes, location])->
    #console.log "#{matcher}", nodes
    data = []
    for node in nodes
        if node instanceof Array
            if node[0].ignoreOutput
                continue

            if node[0].parent?.ignoreOutput
                continue

            data.push process node
        else if node instanceof AstNode
            if node.definition.ignoreOutput
                continue

            if node.definition?.parent?.ignoreOutput
                continue
            data.push node
        else
            data.push node

    fn = matcher.options.process
    if fn?
        result = fn data
        result.start = location
        return result

    return data[0]

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
        process ast
