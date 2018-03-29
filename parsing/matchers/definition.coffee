Flags = require './flags'
Matcher = require './matcher'

module.exports =
class Definition extends Matcher
    @flags |= Flags.ADD_DIRECTLY_AS_RULE
    @flags |= Flags.INHERIT_PARENT_ID

    init: (options, @definition)->
        if @definition == Matcher.Empty
            @matchers = []
            @symbols = []
        else
            @matchers = @definitionToMatchers @definition
            @symbols = @matchersToSymbols @matchers

    toString: ->
        if @matchers.length == 0
            "[#{@parent}: empty]"
        else
            "[#{@parent}: #{@matchers.join(" ")}]"
