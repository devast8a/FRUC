Any = require './any'

module.exports =
class Rule extends Any
    init: (options, @label)->

    toString: -> "<#{@label}>"

