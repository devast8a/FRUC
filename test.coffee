fs = require 'fs'
{Node, Value} = require './parser/ast'

Fmt = require 'fmt'
fmt = new Fmt
    filterByKey: Fmt.reject ['metadata', 'map']

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

compile = (inPath, outPath)->
    try
        fs.accessSync('./grammars/fg/index.js')
        grammar = require './grammars/fg'
        delete require.cache[require.resolve('./grammars/fg')]
    catch e
        grammar = require './grammars/fg/backup'
        delete require.cache[require.resolve('./grammars/fg/backup')]

    Parser = require './parser'
    parser = new Parser grammar

    input = fs.readFileSync inPath, 'utf8'
    ast = parser.parse input

    #console.log fmt.format ast

    output = new Output
    output.require_path = '../../'
    output.pushElement ast

    fs.writeFileSync outPath, output.output
    return output.output

console.log "Compiling a"
a = compile './grammars/fg/index.fg', './grammars/fg/index.js'

console.log "Compiling b"
b = compile './grammars/fg/index.fg', './grammars/fg/index.js'

console.log "Compiling c"
c = compile './grammars/fg/index.fg', './grammars/fg/index.js'

console.log a == b and b == c
