module.exports =
class Matcher
    @flags = 0

    init: ->

    getOption: (name)->
        obj = this
        while obj?
            value = obj.options[name]
            if value != undefined
                return value

            value = obj.constructor.options?[name]
            if value != undefined
                return value

            obj = obj.parent

        return @grammar.options[name]

    setOption: (name, value)->
        @options[name] = value
        @invalidateChildren()

    createMatcher: (constructor, options, args...)->
        options ?= {}
        options.parent = this
        @grammar.createMatcher constructor, options, args...

    definitionToMatcher: (definition)->
        @grammar.definitionToMatcher this, definition

    definitionToMatchers: (definition)->
        if definition instanceof Array
            return (@definitionToMatcher d for d in definition)
        return [@definitionToMatcher definition]

    matcherToSymbol: (matcher)->
        matcher.name

    matchersToSymbols: (matchers)->
        (@matcherToSymbol matcher for matcher in matchers)

    postprocess: -> throw new Error "#{@constructor.name} must implement #{@constructor.name}::postprocess"
    getNodes: -> throw new Error "#{@constructor.name} must implement #{@constructor.name}::getNodes"
    generate: -> throw new Error "#{@constructor.name} must implement #{@constructor.name}::generate"

Matcher.Empty = {'special': 'none'}
