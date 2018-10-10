{Node, Value} = require '../ast'
Builder = require '../grammar/builder'

getEnd = (nodes, location)->
    if nodes.length > 0
        md = nodes[nodes.length - 1].metadata
        return md[md.length - 1].end
    return location

class UnprocessedNode
    constructor: (@definition, @unprocessed, @location)->
        @dispatched = false
        @processed = []
        @parent = []

module.exports =
class Matcher
    setNameAndId: ->
        @id = @grammar.getNextId()
        @name = @id.toString()

    constructor: (@grammar, args, @options)->
        @options ?= {}
        @parent = @options.parent ? null
        @grammar.matchers.push this
        @setNameAndId()

        if args?
            @init args...
        else
            @init()

    noBetween: false
    optional: false

    init: ->

    toString: -> "#{@constructor.name}"
    # inspect: -> @toString()

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
        new UnprocessedNode this, data, location

    dispatch: (node, stack)->
        index = node.unprocessed.length
        while index > 0
            child = node.unprocessed[--index]
            child.parent = node.processed
            stack.push child
        return

    preprocess: (node, map)->
        data = node.unprocessed
        location = node.location

        nodes = node.processed
        #nodes = node.unprocessed.map (node)->node.definition.preprocess node, map
        end = getEnd nodes, location

        # Strip ignored output
        stripped = []
        for i in [0...nodes.length]
            if data[i].definition.ignoreOutput or data[i].definition.parent?.ignoreOutput
                continue
            stripped.push nodes[i]

        if @options.automatic_process and stripped.length == 1
            root = stripped[0]
        else if @options.process
            if @options.process.prototype instanceof Node
                root = new @options.process this, data, nodes
            else
                root = @options.process stripped
                
                if not (root instanceof Node)
                    root = new Value root
        else if stripped.length == 1
            root = stripped[0]
        else
            root = new Node this, data, nodes


        # Get line and column information
        root.metadata.push {
            definition: this
            start: map.offsetToInfo location
            end: end
            nodes: data
        }

        return root

    getNodes: -> throw new Error "#{@constructor.name} must implement #{@constructor.name}::getNodes"
    generate: -> throw new Error "#{@constructor.name} must implement #{@constructor.name}::generate"
