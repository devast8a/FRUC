Flags = require './matchers/flags'
Rule = require './matchers/rule'

Constant = require './matchers/constant'
Matcher = require './matchers/matcher'
Builder = require './matchers/builder'
Regex = require './matchers/regex'

module.exports =
class Grammar
    constructor: ->
        @rules = new Map
        @matchers = []

        @lastId = 0
        @ParserRules = []
        @ParserRules.map = => @ParserRules

        # Built-in matchers
        @root = @rule '.root'

        @ParserStart = @root.name

    createMatcher: (constructor, options, args...)->
        options ?= {}
        matcher = new constructor

        matcher.grammar = this
        
        if (constructor.flags & Flags.ADD_DIRECTLY_AS_RULE) > 0
            @ParserRules.push matcher

        if (constructor.flags & Flags.INHERIT_PARENT_ID) > 0
            if not options.parent?
                throw new Error "Expected parent to be filled"

            matcher.id = options.parent.id
            matcher.name = options.parent.name
            matcher.parent = options.parent
        else
            matcher.id = @lastId++
            matcher.name = matcher.id.toString()
            matcher.parent = options.parent

        @matchers.push matcher
        matcher.init options, args...

        return matcher

    rule: (name)->
        if @rules.has name
            return @rules.get name

        rule = @createMatcher Rule, null, name
        @rules.set name, rule
        return rule

    # Implements simple DSL where this.xyz is the same as grammar.rule('xyz')
    define: (fn)->
        target = {}
        proxy = new Proxy target,
            get: (target, property, receiver)=>
                @rule property
        fn.call proxy

    definitionToMatcher: (parent, definition)->
        type = typeof definition

        # Handle other types
        if type == 'string'
            return @createMatcher Constant, {parent: parent}, definition

        # Handle objects
        if type != 'object'
            throw new Error "Unable to convert input with type #{type} to a matcher"

        if definition instanceof Matcher
            return definition

        if definition instanceof Builder
            return definition.build parent

        if definition instanceof RegExp
            return @createMatcher Regex, {parent: parent}, definition

        throw new Error "Unable to convert input with constructor #{definition.constructor.name} to a matcher"
