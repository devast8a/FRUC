{Node, Value} = require '../ast'
Builder = require '../grammar/builder'

ADD_DIRECTLY_AS_RULE =  0x01
INHERIT_PARENT_ID =     0x02

module.exports =
class Matcher
    @Flags = {
        ADD_DIRECTLY_AS_RULE: ADD_DIRECTLY_AS_RULE
        INHERIT_PARENT_ID: INHERIT_PARENT_ID
    }

    @flags = 0

    hasFlag: (flag)->
        (@constructor.flags & flag) > 0

    constructor: (@grammar, args, @options)->
        @options ?= {}
        @parent = @options.parent ? null

        if @hasFlag ADD_DIRECTLY_AS_RULE
            @grammar.ParserRules.push this

        if @hasFlag INHERIT_PARENT_ID
            if not @parent?
                throw new Error "Expected parent to be filled"
            @id = @parent.id
            @name = @parent.name
        else
            @id = @grammar.getNextId()
            @name = @id.toString()

        @grammar.matchers.push this

        if args?
            @init args...
        else
            @init()

    noBetween: false
    optional: false

    init: ->

    toString: -> "#{@constructor.name}"
    inspect: -> @toString()

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

    new: (constructor, args, options)->
        options ?= {}
        options.parent = this
        new constructor @grammar, args, options

    _definitionToMatcher: (definition)->
        @grammar.definitionToMatcher this, definition

    definitionToMatcher: (definition)->
        if definition instanceof Array
            rule = @grammar.rule(":"+@grammar.lastId)
            rule.add definition
            return rule
        return @_definitionToMatcher definition

    definitionToMatchers: (definition)->
        if definition instanceof Array
            return (@_definitionToMatcher d for d in definition)
        return [@_definitionToMatcher definition]

    matcherToSymbol: (matcher)->
        matcher.name

    matchersToSymbols: (matchers)->
        (@matcherToSymbol matcher for matcher in matchers)

    # Nearley post processing function, keep a reference to the matcher and the location
    postprocess: (data, location, reject)->
        [this, data, location]

    preprocess: (data, location, map, ignore_process)->
        nodes = data.map (node)->node[0].preprocess node[1], node[2], map
        output = []
        for i in [0...nodes.length]
            if data[i][0].ignoreOutput or data[i][0].parent?.ignoreOutput
                continue
            output.push nodes[i]

        if nodes.length > 0
            md = nodes[nodes.length - 1].metadata
            end = md[md.length - 1].end
        else
            end = location

        if @options.process? and !ignore_process
            if @options.process.prototype instanceof Node
                output = new @options.process output...
            else
                output = @options.process output
            if not (output instanceof Node)
                output = new Value output
        else if output.length == 1
            output = output[0]
        else
            output = new Node output...

        # Get line and column information
        for entry in map
            if location < entry.end
                line = entry.line
                column = location - entry.start
                break

        output.metadata.push {
            definition: this
            start: {
                offset: location
                line: line + 1
                column: column + 1
            }
            end: end
            nodes: data
        }

        return output

    getNodes: -> throw new Error "#{@constructor.name} must implement #{@constructor.name}::getNodes"
    generate: -> throw new Error "#{@constructor.name} must implement #{@constructor.name}::generate"

Matcher.Empty = {'special': 'none'}
