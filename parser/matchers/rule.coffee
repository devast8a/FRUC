Any = require './any'

module.exports =
class Rule extends Any
    init: (@label)->
        super()
        @rules = new Map

    toString: -> "<#{@label}>"

    rule: (name)->
        if @rules.has name
            return @rules.get name

        rule = @new Rule, ["#{@label}.#{name}"]
        @rules.set name, rule
        return rule
