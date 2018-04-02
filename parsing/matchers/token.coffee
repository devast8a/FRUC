AstNode = require '../grammar/astnode'
Flags = require '../grammar/flags'

Matcher = require './matcher'

module.exports =
class Token extends Matcher
    @flags |= Flags.ADD_DIRECTLY_AS_RULE

    init: (@token)->
        @symbols = [this]

    test: (token)->
        token.constructor == Object and token.name == @token

    toString: -> "%#{@token}"

    postprocess: (data, location)->
        # Not sure what to return here
        return new AstNode this, data, location, location + 1

    getNodes: -> false
    generate: (tokens)-> tokens.push {name: @token}
