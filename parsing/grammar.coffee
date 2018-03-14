nearley = require 'nearley'
fmt = require 'fmt'
Arr = require 'sweet-coffee/arr'

Flags = {
    ADD_DIRECTLY_AS_RULE:   0x01
    INHERIT_PARENT_ID:      0x02
}

class AstNode
    constructor: (@definition, @data, @start, @end)->
        if @definition.label?
            @label = @definition.label

getEnd = (data)->
    if data instanceof AstNode
        return data.end

    if data instanceof Array
        for entry in data by -1
            if (end = getEnd entry) != null
                return end

    return null

AstNode.getEnd = (data, location)->
    if (data instanceof Array) and data.length == 0
        return location
    getEnd data

class Matcher
    @flags = 0

    definitionToMatcher: (definition)->
        type = typeof definition

        if type == 'string'
            return @grammar.createMatcher null, Constant, definition

        if type != 'object'
            throw new Error "Unable to convert input with type #{type} to a matcher"

        if definition instanceof Matcher
            return definition

        if definition instanceof Builder
            return definition.build this

        throw new Error "Unable to convert input with constructor #{definition.constructor.name} to a matcher"

    definitionsToMatchers: (definition)->
        if definition instanceof Array
            return (@definitionToMatcher d for d in definition)
        [@definitionToMatcher definition]

    matcherToSymbol: (matcher)->
        matcher.name

    matchersToSymbols: (matchers)->
        (@matcherToSymbol matcher for matcher in matchers)

Matcher.None = {}

class Definition extends Matcher
    @flags |= Flags.ADD_DIRECTLY_AS_RULE
    @flags |= Flags.INHERIT_PARENT_ID

    init: (definition)->
        @setDefinition definition

    setDefinition: (definition)->
        if definition == Matcher.None
            @definition = []
            @symbols = []
            return

        @definition = @definitionsToMatchers definition

        between = @grammar.between
        matchers = []

        for matcher in @definition
            matchers.push matcher
            matchers.push between
        matchers.pop()

        @symbols = @matchersToSymbols matchers

    postprocess: (data, location, reject)->
        end = AstNode.getEnd data, location
        new AstNode this, data, location, end

    inspect: ->
        name = @parent.label

        body = @definition
        .map (x)->x.inspect()
        .join " "

        name + " => " + body

    remove: ->
        @parent.remove this

class Any extends Matcher
    init: ->
        @definitions = []

    add: (definition, options = null)->
        if @optionalEmpty
            @remove @optionalEmpty
            @optionalEmpty = null

        matcher = @grammar.createMatcher {parent: this}, Definition, definition
        @definitions.push matcher
        return matcher

    remove: (definition)->
        if Arr.m_removeValue(definition, @definitions) == 0
            return false

        if Arr.m_removeValue(definition, @grammar.ParserRules) == 0
            return false

        return true

    optionalEmpty: null
    setOptionalWhenEmpty: (@optionalWhenEmpty)->
        if @optionalWhenEmpty
            if @optionalEmpty == null
                @optionalEmpty = @add Matcher.None
        else
            if @optionalEmpty != null
                @optionalEmpty.remove()

    getNodes: -> (d.definition for d in @definitions)
    generate: ->

class Rule extends Any
    init: (@label)->
        super()

    inspect: -> "<#{@label}>"
    toString: -> "<#{@label}>"

class Constant extends Matcher
    @flags |= Flags.ADD_DIRECTLY_AS_RULE

    init: (constant)->
        @setConstant constant

    setConstant: (@constant)->
        @symbols = (literal: c for c in @constant)

    postprocess: (data, location, reject)->
        new AstNode this, data.join(''), location, location + data.length

    getNodes: -> []
    generate: (tokens)->
        last = tokens[tokens.length - 1]
        if typeof(last) == 'string'
            tokens.pop()
            tokens.push last + @constant
        else
            tokens.push @constant

    inspect: -> "`#{@constant}`"
    toString: -> "`#{@constant}`"

class Builder
    constructor: (@matcher, @args)->
    build: (parent)->
        parent.grammar.createMatcher null, @matcher, @args...

class Grammar
    constructor: ->
        @rules = new Map
        @matchers = []

        @lastId = 0

        @ParserRules = []
        @ParserRules.map = => @ParserRules

        # Special rules
        @root = @rule '.root'
        @between = @rule '.between'
        @between.setOptionalWhenEmpty true

        @ParserStart = @root.name

    rule: (name)->
        if @rules.has name
            return @rules.get name

        rule = @createMatcher null, Rule, name

        @rules.set name, rule
        return rule

    createMatcher: (options, constructor, args...)->
        matcher = new constructor

        # The matcher should be directly added to the list of parsers
        if (constructor.flags & Flags.ADD_DIRECTLY_AS_RULE) > 0
            @ParserRules.push matcher

        if (constructor.flags & Flags.INHERIT_PARENT_ID) > 0
            if (not options?) or (not options.parent?)
                throw new Error "Expected parent"

            matcher.id = options.parent.id
            matcher.name = options.parent.name
            matcher.parent = options.parent
        else
            matcher.id = @lastId++
            matcher.name = matcher.id.toString()

        matcher.grammar = this
        @matchers.push matcher
        matcher.init args...

        return matcher

    define: (fn)->
        target = {}
        proxy = new Proxy target,
            get: (target, property, receiver)=>
                @rule property
        fn.call proxy

class Optional extends Any
    init: (@rule)->
        super()

        @add Matcher.None
        @add @rule

    inspect: -> "Optional(#{@rule})"
    toString: -> "Optional(#{@rule})"

class Repeat extends Any
    init: (@rule, options = null)->
        super()

        if options != null
            separator = options.separator

            @add [this, separator, @rule]
            @add @rule
        else
            @add [this, @rule]
            @add @rule

    inspect: -> "Repeat(#{@rule})"
    toString: -> "Repeat(#{@rule})"

class OptionalRepeat extends Any
    init: (@rule)->
        super()

        @add Opt(Rep(@rule))

    inspect: -> "OptionalRepeat(#{@rule})"
    toString: -> "OptionalRepeat(#{@rule})"

Rep = (args...)-> new Builder Repeat, args
Opt = (args...)-> new Builder Optional, args
Token = (args...)-> new Builder TokenM, args

class Parser
    constructor: (@grammar)->
        @_parser = new nearley.Parser @grammar.ParserRules, @grammar.ParserStart

    feed: (symbols)->
        @_parser.feed symbols

    results: ->
        return @_parser.results

exports.Opt = Opt
exports.Rep = Rep
exports.Grammar = Grammar
