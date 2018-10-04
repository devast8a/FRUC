{Value} = require '../ast'

Matcher = require './matcher'

module.exports =
class Token extends Matcher
    init: (@token)->
        @grammar.ParserRules.push this

        @symbols = [this]

    test: (token)->
        token.constructor == Object and token.token == @token

    toString: -> "%#{@token}"

    getNodes: -> false
    generate: (tokens)-> tokens.push {name: @token}
    ignoreOutput: true

    preprocess: (data, location, map)->
        # TODO: Provide better mapping
        data = data[0]
        node = new Value data
        node.metadata.push {
            definition: this
            start: map.offsetToInfo location
            end: map.offsetToInfo location + 1
        }
        return node
