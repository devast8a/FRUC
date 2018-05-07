Any = require './any'
Matcher = require './matcher'

module.exports =
class Optional extends Any
    init: (rule)->
        super()
        @add rule

    toString: -> "Optional(#{@rule})"

    # Hack to avoid issues with optional rules
    noBetween: true
    optional: true
