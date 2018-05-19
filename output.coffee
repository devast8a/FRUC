{Node, Value} = require './parser/ast'

module.exports =
class Output
    current_indent: ''
    output: ''

    IN: ['indent']
    OUT: ['dedent']

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

    push: (elements...)->
        @pushElement elements

    indent: ->
        @newline = true
        @current_indent += '    '
    dedent: ->
        @newline = !@newline
        @current_indent = @current_indent[...-4]

    pushElement: (element)->
        if element == @IN
            @indent()
        else if element == @OUT
            @dedent()
        else if element instanceof Value
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
            for e in element
                @pushElement e
        else
            throw new Error "Unknown element type"
