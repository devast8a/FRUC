Any = require './any'

module.exports =
class Rule extends Any
    init: (@label)->
        super()

    toString: -> "<#{@label}>"

