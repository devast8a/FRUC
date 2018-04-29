Matcher = require './matcher'
Definition = require './definition'
AstNode = require '../grammar/astnode'

module.exports =
class Any extends Matcher
    init: ->
        @definitions = []


    add: (definition, options)->
        if typeof(options) == 'function'
            options = {process: options}

        if options? and options.process? and options.process.prototype instanceof AstNode
            cons = options.process
            options.astnode = cons
            options.process = (data)->
                new cons data...

        if options? and options.ignore
            @ignoreOutput = options.ignore

        matcher = @createMatcher Definition, options, definition
        @definitions.push matcher
        return matcher

    toString: -> "<##{@name}>"

    getNodes: -> (d.matchers for d in @definitions)
    generate: ->
