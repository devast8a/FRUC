Builder = require './builder'

Rule = require '../matchers/rule'
Constant = require '../matchers/constant'
Matcher = require '../matchers/matcher'
Regex = require '../matchers/regex'

module.exports =
class Grammar
    constructor: ->
        @options = {}
        @rules = new Map
        @matchers = []

        @lastId = 0
        @ParserRules = []
        @ParserRules.map = => @ParserRules

        # Built-in matchers
        @root = @rule '.root'

        @between = @rule '.between',
            between: null

        @between.ignoreOutput = true

        # Set base options
        @options.between = @between
        @options.optionalEmptyValue = []

        @ParserStart = @root.name

    createMatcher: (constructor, options, args...)->
        new constructor this, args, options

    getNextId: -> @lastId++

    rule: (name, options = null)->
        if @rules.has name
            return @rules.get name

        rule = @createMatcher Rule, options, name
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
