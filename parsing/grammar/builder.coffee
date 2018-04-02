module.exports =
class Builder
    constructor: (@matcher, @options, @args...)->
        @options ?= {}

    build: (parent)->
        @options.parent = parent
        parent.grammar.createMatcher @matcher, @options, @args...
