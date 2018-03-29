module.exports =
class Matcher
    @flags = 0

    init: ->

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

Matcher.Empty = {'special': 'none'}
