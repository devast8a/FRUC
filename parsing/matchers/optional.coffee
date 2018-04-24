Any = require './any'
Matcher = require './matcher'

# NOTE: matcher.coffee contains copies of these values
# If you change them here make sure to change them there too
FRONT   = 0x01
BACK    = 0x02
MIDDLE  = 0x03

module.exports =
class Optional extends Any
    init: (rule, direction)->
        super()
        @emptyValue = @getOption 'optionalEmptyValue'

        @rule = @definitionToMatcher rule

        between = @getOption 'between'
        if between == null
            @match = @add @rule
            @empty = @add Matcher.Empty, => @emptyValue
        else
            switch direction
                when FRONT
                    @match = @add [@rule, between], between: null
                    @empty = @add Matcher.Empty, => @emptyValue
                when MIDDLE
                    @match = @add [between, @rule, between], between: null
                    @empty = @add between, => @emptyValue
                when BACK
                    @match = @add [between, @rule], between: null
                    @empty = @add Matcher.Empty, => @emptyValue
                else
                    throw new Error "Invalid direction value"

    toString: -> "Optional(#{@rule})"

    # Hack to avoid issues with optional rules
    noBetween: true

    FRONT: FRONT
    BACK: BACK
    MIDDLE: MIDDLE
