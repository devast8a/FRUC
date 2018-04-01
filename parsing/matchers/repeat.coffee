Any = require './any'

repeat = (data)->
    data[0].data.concat data[1]

module.exports =
class Repeat extends Any
    toString: -> "Repeat(#{@rule})"

    init: (rule)->
        super()
        @rule = @definitionToMatcher rule

        separator = @getOption 'separator'
        type = @getOption 'type'

        if separator
            @tail = @add @rule
            @repeat = @add [this, separator, @rule], repeat
        else
            @tail = @add @rule
            @repeat = @add [this, @rule], repeat
