Any = require './any'
Matcher = require './matcher'

module.exports =
class Optional extends Any
    init: (rule)->
        super()
        @emptyValue = @getOption 'optionalEmptyValue'

        @rule = @definitionToMatcher rule

        between = @getOption 'between'

        if between == null
            @match = @add @rule
            @empty = @add Matcher.Empty, => @emptyValue
        else
            @match = @add [between, @rule, between], between: null
            @empty = @add between, => @emptyValue

    toString: -> "Optional(#{@rule})"

    # Hack to avoid issues with optional rules
    noBetween: true
