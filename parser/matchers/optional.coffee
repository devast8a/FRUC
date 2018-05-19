Any = require './any'
Matcher = require './matcher'

module.exports =
class Optional extends Any
    optional: true

    init: (@rule)->
        super()
        rule = @add @rule
        @noBetween = @rule.noBetween
        @ignoreOutput = @rule.ignoreOutput

    toString: -> "Optional(#{@rule})"
