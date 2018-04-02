AstNode = require './astnode'
Flags = require './flags'
Matcher = require './matcher'

preprocess = (data, location, reject)->
    end = AstNode.getEnd data, location

    if @options.process?
        stripped = []
        for node in data
            if node.definition.ignoreOutput
                continue

            if node.definition.parent.ignoreOutput
                continue

            stripped.push node

        data = @options.process stripped, location, reject

    if data == reject
        return reject

    return new AstNode this, data, location, end

module.exports =
class Definition extends Matcher
    @flags |= Flags.ADD_DIRECTLY_AS_RULE
    @flags |= Flags.INHERIT_PARENT_ID

    init: (@definition)->
        pp = @options.preprocess
        if pp?
            @postprocess = pp

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
            "[#{@parent}: empty]"
        else
            "[#{@parent}: #{@matchers.join(" ")}]"

    postprocess: preprocess
