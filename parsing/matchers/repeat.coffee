Any = require './any'

module.exports =
class Repeat extends Any
    toString: -> "Repeat(#{@rule})"

    init: (options, rule)->
        super()
        @rule = @definitionToMatcher rule

        if options.separator
            @add @rule
            @add [this, options.separator, @rule]
        else
            @add @rule
            @add [this, @rule]
