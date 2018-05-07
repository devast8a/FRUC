Matcher = require './matcher'
Builder = require '../grammar/builder'

class Symbols
    constructor: (@grammar, [@symbols], @options)->
        @parent = @options.parent
        @name = @options.parent.name

    postprocess: (data, location, reject)->
        [@parent, data, location]

class Empty extends Symbols

class Any extends Matcher
    class: null

    init: (definitions)->
        @definitions = []

        if definitions?
            for definition in definitions
                @add definition

    add: (definition, options)->
        if typeof(options) == 'function'
            options = {process: options}

        matcher = @new @class, [definition], options
        @definitions.push matcher
        return matcher

    toString: -> "Any()"

class Optional extends Any
    @FRONT = 1
    @BACK = 2
    @MIDDLE = 3
    @NONE = 4

    class: Symbols

    init: (@direction, @rule, between)->
        super()
        rule = @rule.name
        between = between?.name

        switch @direction
            when Optional.FRONT
                @match = @add [rule, between]
                @empty = @add []
            when Optional.MIDDLE
                @match = @add [between, rule, between]
                @empty = @add [between]
            when Optional.BACK
                @match = @add [between, rule]
                @empty = @add []
            when Optional.NONE
                @match = @add [rule]
                @empty = @add []
            else
                throw new Error 'Direction must be set'

        @grammar.ParserRules.push @match
        @grammar.ParserRules.push @empty

getDirection = (front, back, index)->
    if index <= front then return Optional.FRONT
    if index >= back then return Optional.BACK
    return Optional.MIDDLE

module.exports =
class Definition extends Matcher
    setNameAndId: ->
        if not @parent?
            throw new Error "parent must be set when using Definition"

        @id = @parent.id
        @name = @parent.name

    init: (@definition)->
        @containers = []

        if @definition == Matcher.Empty
            @matchers = []
            @symbols = []
            @optional = true
            @grammar.ParserRules.push @new Symbols, [@symbols]
        else
            between = @getOption 'between'
            matchers = @definitionToMatchers @definition
            @optional = matchers.every (matcher)->matcher.optional

            if between == null
                @matchers = matchers.map (matcher)=>
                    if matcher.optional
                        return @new(Optional, [Optional.NONE, matcher])
                    return matcher

                @symbols = @matchersToSymbols @matchers
                @grammar.ParserRules.push @new Symbols, [@symbols]
            else
                back = matchers.length
                front = -1

                while back > 0 and matchers[back - 1].optional
                    back -= 1

                while front < back and matchers[front + 1].optional
                    front += 1

                if back == 0
                    optionals = matchers[1..].map (matcher)=>
                        @new(Optional, [Optional.BACK, matcher, between]).name

                    for matcher, index in matchers
                        container = @new Symbols, [[matcher.name].concat(optionals[index..])]
                        @containers.push container
                        @grammar.ParserRules.push container
                else
                    @matchers = []
                    
                    if matchers[0].optional
                        @matchers.push @new Optional, [getDirection(front, back, 0), matchers[0], between]
                    else
                        @matchers.push matchers[0]

                    NOBETWEEN = matchers[0].noBetween or matchers[0].optional

                    for matcher, index in matchers[1..]
                        if NOBETWEEN or matcher.noBetween or matcher.optional
                            NOBETWEEN = false
                        else
                            @matchers.push between

                        if matcher.optional
                            @matchers.push @new Optional, [getDirection(front, back, index + 1), matcher, between]
                        else
                            @matchers.push matcher
                        NOBETWEEN = matcher.noBetween or matcher.optional

                    @symbols = @matchersToSymbols @matchers
                    @grammar.ParserRules.push @new Symbols, [@symbols]

    toString: ->
        if @matchers.length == 0
            "(#{@parent}: empty)"
        else
            "(#{@parent}: #{@matchers.join(" ")})"
