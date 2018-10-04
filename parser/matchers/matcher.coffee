{Node, Value} = require '../ast'
Builder = require '../grammar/builder'

getEnd = (nodes, location)->
    if nodes.length > 0
        md = nodes[nodes.length - 1].metadata
        return md[md.length - 1].end
    return location

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
        [this, data, location]

    preprocess: (data, location, map, ignore_process)->
        nodes = data.map (node)->node[0].preprocess node[1], node[2], map
        end = getEnd nodes, location

        # Strip ignored output
        stripped = []
        for i in [0...nodes.length]
            if data[i][0].ignoreOutput or data[i][0].parent?.ignoreOutput
                continue
            stripped.push nodes[i]

        if @options.automatic_process and stripped.length == 1
            root = stripped[0]
        else if @options.process and !ignore_process
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
