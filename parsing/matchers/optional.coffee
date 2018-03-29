Any = require './any'
Matcher = require './matcher'

module.exports =
class Optional extends Any
    toString: -> "Optional(#{@rule})"

    init: (options, rule)->
        super()
        @rule = @definitionToMatcher rule
        @add @rule
        @add Matcher.Empty
