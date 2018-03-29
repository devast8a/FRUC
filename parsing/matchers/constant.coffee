Flags = require './flags'
Matcher = require './matcher'

module.exports =
class Constant extends Matcher
    @flags |= Flags.ADD_DIRECTLY_AS_RULE

    init: (options, value)->
        @setValue value

    setValue: (@value)->
        @symbols = (literal: c for c in @value)

    toString: -> "`#{@value}`"
