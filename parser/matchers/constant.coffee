{Value} = require '../ast'

Matcher = require './matcher'

module.exports =
class Constant extends Matcher
    init: (value)->
        @grammar.ParserRules.push this

        @setValue value

    setValue: (@value)->
        @symbols = (literal: c for c in @value)

    toString: -> "`#{@value}`"

    getNodes: -> false
    generate: (tokens)-> tokens.push @value
    unparse: (tokens)-> tokens.push @value

    ignoreOutput: true

    # Function that handles the processing 
    preprocess: (data, location, map)->
        data = data.join ''

        for entry in map
            if location < entry.end
                start_line = entry.line
                start_column = location - entry.start
                break

        end = location + data.length
        for entry in map
            if end < entry.end
                end_line = entry.line
                end_column = end - entry.start
                break

        node = new Value data
        node.metadata.push {
            definition: this
            start: {
                offset: location
                line: start_line + 1
                column: start_column + 1
            }
            end: {
                offset: location + data.length
                line: end_line + 1
                column: end_column + 1
            }
        }
        return node
