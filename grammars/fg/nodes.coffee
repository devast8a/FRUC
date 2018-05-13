{Node, Value} = require 'parser/ast'

Node::getByType = (type)->
    output = []
    for child in @childNodes
        if child instanceof type
            output.push child
    return output

_join = (list, output)->
    for element in list.childNodes
        if typeof(element.data) == 'string' and element instanceof Value
            output.push element.data
        else
            _join element, output
    return

Node.join = (list, glue)->
    output = []
    _join list, output
    return output.join glue


exports.Rule =
class Rule extends Node
    init: (name, @definition, @tag, body)->
        @name = name.childNodes[name.childNodes.length - 1]
        @others = name.childNodes[..-2]

        if body instanceof Processor
            @options = []
            @processors = [body]
            @subrules = []
        else
            # Extract options
            @options = body.getByType Option
            @processors = body.getByType Processor
            @subrules = body.getByType Rule

        if @tag instanceof Reference
            value = (node.identifier.data for node in @tag.identifiers).join '.'
            @options.push ['process: tags.', value]

        if @processors.length > 1
            throw new Error "Only allowed one processor"

        @options = @options.concat @processors

    outputJS: (output)->
        output.push [@name, ".add([", @definition, "]"]

        if @options.length > 0
            output.push ", {"
            output.indent()
            output.join @options, ",\n"
            output.dedent()
            output.push "}"
        
        output.push [")"]

        # Others
        if @others.length > 0
            output.indent()
            output.push ['// Linked\n']

            for other in @others
                output.push [other, '.add([', @name, '])\n']

            output.dedent()

        # Subrules
        if @subrules.length > 0
            output.indent()
            output.push ['// Subrules\n']
            output.join @subrules, '\n'
            output.dedent()

exports.Identifier =
class Identifier extends Node
    init: (@identifier)->
    outputJS: (output)->output.push [@identifier]

exports.Token =
class Token extends Node
    init: (@identifier)->
    outputJS: (output)->output.push ['Token("', @identifier, '")']

exports.String =
class String extends Node
    init: (@string)->
    outputJS: (output)->output.push ['\'', @string, '\'']

exports.Regex =
class Regex extends Node
    init: (@regex)->
    outputJS: (output)->output.push ['/', @regex, '/']

exports.Reference =
class Reference extends Node
    init: (@global, identifiers)->
        @grammar = @global.data == '@'
        @identifiers = identifiers.childNodes
        @name = Node.join identifiers, '.'

    outputJS: (output)->
        if @grammar
            output.push ["grammar."]
            output.join @identifiers, "."
        else
            #console.log "#{@name} == #{@target}"

            output.push ["R('", @target.replace(/\./g, "').rule('"), "')"]

exports.Definition =
class Definition extends Node
    init: (matchers)->
        @matchers = matchers.childNodes
    outputJS: (output)->
        output.join @matchers, ", "

exports.Option =
class Option extends Node
    init: (@name, @value)->
    outputJS: (output)->
        if output.scope == 'DOCUMENT'
            output.push ['grammar.', @name, '=', @value]
        else
            output.push [@name, ': ', @value]

exports.Processor =
class Processor extends Node
    init: (data)->
        [@parameters, data] = data.childNodes
        if data.data?
            @line = data
        else
            @body = data.childNodes[1]

    outputJS: (output)->
        if output.scope == 'DOCUMENT'
            if @body?
                body = (line.childNodes[0].data.trim() for line in @body.childNodes)
                output.join body, '\n'
            else
                output.push [@line.data.trim()]
        else
            # Handle special values
            output.push ['process: function(){']
            output.indent()
            if @body?
                body = (line.childNodes[0].data.trim() for line in @body.childNodes)
                output.join body, '\n'
            else
                output.push ['return ', @line.data.trim()]
            output.dedent()
            output.push ['}']

Repeat = (name)->
    class RepeatImpl extends Node
        init: (@rule, @separator)->
        outputJS: (output)->
            if @separator?.childNodes.length > 0
                output.push [name, "(", @rule, ", {separator: ", @separator, "})"]
            else
                output.push [name, "(", @rule, ")"]

exports.Opt = Repeat 'Opt'
exports.Rep = Repeat 'Rep'
exports.OptRep = Repeat 'OptRep'

exports.Document =
class Document extends Node
    init: (_, statements)->
        @processors = statements.getByType Processor
        @options = statements.getByType Option
        @rules = statements.getByType Rule

    outputJS: (output)->
        resolver = new NameResolver
        resolver.process @rules
        resolver.resolve()

        output.require_path ?= "fruc/"
        output.node_path ?= "./nodes"

        output.push ["""
            var Grammar = require("#{output.require_path}parser/grammar")
            var {Rep, Opt, OptRep, Token, importSpace} = require("#{output.require_path}parser/grammar/helpers")
            var grammar = new Grammar()
            module.exports = grammar
            grammar.define(function(){
                function R(rule){
                    return grammar.rule(rule)
                }
                var {SPACE, NO_SPACE, SPACE_NL, NEWLINE} = importSpace(grammar)
                grammar.SPACE = SPACE
                grammar.NO_SPACE = NO_SPACE
                grammar.SPACE_NL = SPACE_NL
                grammar.NEWLINE = NEWLINE

                var tags = require('#{output.node_path}')

                grammar.null = null
                grammar.true = true
                grammar.false = false

        """]
        output.indent()

        output.scope = 'DOCUMENT'
        output.join @options, "\n"
        if @options.length > 0
            output.push '\n'
        output.join @processors, "\n"
        if @processors.length > 0
            output.push '\n'
        output.scope = 'RULES'

        output.join @rules, "\n"

        output.dedent()
        output.push ["""

                if(grammar.between.definitions.length == 0){
                    grammar.between.add('')
                }
            });
        """]

class Scope
    constructor: (@parent = null, @name = "")->
        @declared = {}

        if @parent?
            if @parent.name != ''
                @name = @parent.name + '.' + @name

    declare: (name, node)->
        @declared[name] = node

    lookup: (name)->
        if @declared[name]?
            return @declared[name]
        else if @parent?
            return @parent.lookup name
        else
            return null

class NameResolver
    process: (rules)->
        scope = new Scope
        @references = []
        @_process scope, rules

    _process: (scope, nodes)->
        if scope.name == ''
            prefix = ''
        else
            prefix = scope.name + '.'

        for node in nodes
            if node instanceof Rule
                scope.declare node.name.name, {
                    name: node.name.name
                    scope: scope
                    full: prefix + node.name.name
                }
                @_process scope, [node.name]

                for other in node.others
                    scope.declare other.name, {
                        name: other.name
                        scope: scope
                        full: prefix + other.name
                    }
                    @_process scope, [other]

                childScope = new Scope scope, node.name.name
                @_process childScope, node.definition.childNodes
                @_process childScope, node.subrules
            else if node instanceof Reference
                if not node.grammar
                    @reference scope, node.name, node
            else
                @_process scope, node.childNodes

    resolve: ->
        for [scope, name, node] in @references
            symbol = scope.lookup name
            if symbol?
                node.target = symbol.full
            else
                throw new Error "Failed to lookup #{name}"

    reference: (scope, name, node)->
        @references.push [scope, name, node]
