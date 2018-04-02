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

    postprocess: (data, location)->
        data = data.join ''
        return new AstNode this, data, location, location + data.length

    getNodes: -> false
    generate: (tokens)-> tokens.push @value

    ignoreOutput: true
