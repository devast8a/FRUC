Matcher = require './matcher'
Definition = require './definition'
{Node} = require '../ast'

module.exports =
class Any extends Matcher
    init: ->
        @definitions = []


    add: (definition, options)->
        if typeof(options) == 'function'
            options = {process: options}

        if options? and options.process? and options.process.prototype instanceof Node
            cons = options.process
            options.astnode = cons
            options.process = (data)->
                new cons data...

        if options? and options.ignore
            @ignoreOutput = options.ignore

        matcher = @new Definition, [definition], options
        @definitions.push matcher
        return matcher

    toString: -> "<##{@name}>"

    getNodes: -> (d.matchers for d in @definitions)
    generate: ->
