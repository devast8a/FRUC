Matcher = require './matcher'
Definition = require './definition'
{Node} = require '../ast'

class Collection extends Matcher
    init: (definitions)->
        @definitions = []

        if definitions?
            for definition in definitions
                @add definition

    add: (definition, options)->
        if typeof(options) == 'function'
            options = {process: options}

        #TODO: Try and remove these from any
        if options? and options.noBetween
            @noBetween = true

        if options? and options.ignore
            @ignoreOutput = options.ignore

        matcher = @new Definition, [definition], options
        @definitions.push matcher
        return matcher

    remove: (matcher)->
        index = @definitions.indexOf matcher

        if index < 0
            return false

        @definitions[index] = @definitions[@definitions.length - 1]
        @definitions.length -= 1
        return true

    toString: -> "Collection()"

module.exports =
class Any extends Collection
    optionalCount: 0

    add: (definition, options)->
        matcher = super definition, options
        if matcher.optional
            @optionalCount++
            @optional = true
        return matcher

    remove: (matcher)->
        result = super matcher
        if matcher.optional and result
            @optionalCount--
            @optional = @optionalCount > 0
        return result
