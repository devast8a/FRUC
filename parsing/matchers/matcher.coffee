AstNode = require '../grammar/astnode'
AstValue = require '../grammar/astvalue'

module.exports =
class Matcher
    @flags = 0

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

    createMatcher: (constructor, options, args...)->
        options ?= {}
        options.parent = this
        @grammar.createMatcher constructor, options, args...

    definitionToMatcher: (definition)->
        @grammar.definitionToMatcher this, definition

    definitionToMatchers: (definition)->
        if definition instanceof Array
            return (@definitionToMatcher d for d in definition)
        return [@definitionToMatcher definition]

    matcherToSymbol: (matcher)->
        matcher.name

    matchersToSymbols: (matchers)->
        (@matcherToSymbol matcher for matcher in matchers)

    # Nearley post processing function, keep a reference to the matcher and the location
    postprocess: (data, location, reject)->
        [this, data, location]

    preprocess: (data, location, map)->
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

        if @options.process?
            output = @options.process output
            if not (output instanceof AstNode)
                output = new AstValue output
        else if output.length == 1
            output = output[0]
        else
            output = new AstNode output...

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
