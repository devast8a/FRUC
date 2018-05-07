Any = require './any'
Matcher = require './matcher'

module.exports =
class Optional extends Any
    optional: true

    init: (rule)->
        super()
        @add rule

    toString: -> "Optional(#{@rule})"
