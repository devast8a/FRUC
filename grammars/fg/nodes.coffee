{Node} = require 'parser/ast'

Node::getByType = (type)->
    output = []
    for child in @childNodes
        if child instanceof type
            output.push child
    return output

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
        @identifiers = identifiers.childNodes
    outputJS: (output)->
        if @global.data == '@'
            output.push ["grammar."]
            output.join @identifiers, "."
        else
            output.push ["R('"]
            output.join @identifiers, "').rule('"
            output.push ["')"]

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
