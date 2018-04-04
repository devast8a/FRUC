AstNode = require '../grammar/astnode'
Flags = require '../grammar/flags'

Matcher = require './matcher'

module.exports =
class Constant extends Matcher
    @flags |= Flags.ADD_DIRECTLY_AS_RULE

    init: (value)->
        @setValue value

    setValue: (@value)->
        @symbols = (literal: c for c in @value)

    toString: -> "`#{@value}`"

    getNodes: -> false
    generate: (tokens)-> tokens.push @value

    ignoreOutput: true

    # Function that handles the processing 
    preprocess: (data, location)->
        data = data.join ''

        node = new AstNode
        node.data = data
        node.metadata = [{
            definition: this
            start: location
            end: location + data.length
        }]
        return node
