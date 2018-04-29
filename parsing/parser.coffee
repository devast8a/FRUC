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

        parser = new nearley.Parser @grammar.ParserRules, @grammar.ParserStart
        stack = ['']
        prefix = /([ \t]*)([^\r\n]*)(\r\n|\r|\n)/g
        firstLine = true
        while match = prefix.exec input
            [_, indent, data, newline] = match

            # Skip only whitespace lines
            if indent.length == line.length
                parser.feed newline
                continue

            last = stack[stack.length - 1]

            if indent == last
                parser.feed data
                parser.feed newline
            else if indent.startsWith last
                stack.push indent
                parser.feed [{token: 'INDENT'}]
                parser.feed data
                parser.feed newline
            else if last.startsWith indent
                while stack[stack.length - 1] != indent
                    stack.pop()
                    parser.feed [{token: 'DEDENT'}]
                parser.feed '\n'
                parser.feed data
                parser.feed newline
            else
                throw new "Indentation is inconsistent"

            firstLine = false

        while stack.length > 1
            stack.pop()
            parser.feed [{token: 'DEDENT'}]
        
        results = parser.results.map (ast)->
            ast = ast[0].preprocess ast[1], ast[2], map
            ast.map = map
            return ast

        if results.length != 1
            for result in results
                console.log fmt.format result
            throw new Error "Expecting 1 parser result, got #{parser.results.length}"

        return results[0]
