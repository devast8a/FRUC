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
        node = new Value data
        node.metadata.push {
            definition: this
            start: map.offsetToInfo location
            end: map.offsetToInfo location + data.length
        }
        return node
