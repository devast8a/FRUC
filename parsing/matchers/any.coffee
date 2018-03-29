Matcher = require './matcher'
Definition = require './definition'

module.exports =
class Any extends Matcher
    add: (definition, options)->
        @createMatcher Definition, options, definition

    toString: -> "<##{@name}>"
