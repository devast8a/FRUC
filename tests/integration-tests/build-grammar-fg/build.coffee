# Recursively builds a grammar for FRUC grammar language
{expect} = require 'chai'
fs = require 'fs'
{Node, Value} = require 'parser/ast'

Fmt = require 'fmt'
fmt = new Fmt
    filterByKey: Fmt.reject ['metadata', 'map']

it 'builds grammars/fg correctly', ->
    class Output
        current_indent: ''
        output: ''

        INDENT: ['indent']
        DEDENT: ['dedent']

        pushString: (string)->
            if @newline == true
                @newline = false
                @pushString '\n'
            @output += string.replace /\n/g, '\n' + @current_indent

        join: (list, glue)->
            if list instanceof Node
                list = list.childNodes

            push_glue = false
            for element in list
                if push_glue
                    @pushElement glue
                push_glue = true
                @pushElement element

        push: (list)->
            if list instanceof Node
                list = list.childNodes
            for element in list
                @pushElement element

        indent: ->
            @newline = true
            @current_indent += '    '
        dedent: ->
            @newline = !@newline
            @current_indent = @current_indent[...-4]

        pushElement: (element)->
            if element instanceof Value
                if typeof(element.data) == 'string'
                    @pushString element.data
                else if element.data.length == 0
                    return
                else
                    throw new Error ""
            else if element instanceof Node
                if element.outputJS?
                    element.outputJS this
                else
                    throw new Error "#{element.constructor.name} does not have an outputJS function"
            else if typeof(element) == 'string'
                @pushString element
            else if element instanceof Array
                @push element
            else
                throw new Error ""

    require 'grammars/fg/nodes'

    compile = (inPath, grammar)->
        Parser = require 'parser'
        parser = new Parser grammar

        input = fs.readFileSync inPath, 'utf8'
        ast = parser.parse input

        output = new Output
        output.require_path = ''
        output.node_path = 'grammars/fg/nodes'
        output.pushElement ast

        return output.output

    try
        fs.accessSync 'grammars/fg/index.js'
        grammar = require 'grammars/fg'
    catch e
        grammar = require 'grammars/fg/backup'

    module = (text)->
        fn = new Function ['require', 'module', 'exports'], text
        mdl = {exports: {}}
        fn(require, mdl, mdl.exports)
        return mdl.exports

    a = compile './grammars/fg/index.fg', grammar
    b = compile './grammars/fg/index.fg', module(a)
    c = compile './grammars/fg/index.fg', module(b)
    expect(a == b and b == c).equal(true)
    return
