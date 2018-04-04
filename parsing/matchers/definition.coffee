AstNode = require '../grammar/astnode'
Flags = require '../grammar/flags'

Matcher = require './matcher'

module.exports =
class Definition extends Matcher
    @flags |= Flags.ADD_DIRECTLY_AS_RULE
    @flags |= Flags.INHERIT_PARENT_ID

    init: (@definition)->
        if @definition == Matcher.Empty
            @matchers = []
            @symbols = []
        else
            between = @getOption 'between'
            matchers = @definitionToMatchers @definition

            if between == null
                @matchers = matchers
            else
                @matchers = []
                
                @matchers.push matchers[0]
                NOBETWEEN = matchers[0].noBetween ? false

                for matcher in matchers[1..]
                    if NOBETWEEN or matcher.noBetween
                        NOBETWEEN = false
                    else
                        @matchers.push between
                    @matchers.push matcher
                    NOBETWEEN = matcher.noBetween ? false

            @symbols = @matchersToSymbols @matchers

    toString: ->
        if @matchers.length == 0
            "(#{@parent}: empty)"
        else
            "(#{@parent}: #{@matchers.join(" ")})"
