Matcher = require './matcher'
Definition = require './definition'

module.exports =
class Any extends Matcher
    init: ->
        @definitions = []


    add: (definition, options)->
        if typeof(options) == 'function'
            options = {process: options}

        matcher = @createMatcher Definition, options, definition
        @definitions.push matcher
        return matcher

    toString: -> "<##{@name}>"

    getNodes: -> (d.matchers for d in @definitions)
    generate: ->
