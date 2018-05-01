INDENT = {token: 'INDENT'}
DEDENT = {token: 'DEDENT'}

newlineRegex = /(\r\n|\r|\n)/
indentRegex = /^\s*/

module.exports =
class Indentation
    @INDENT = INDENT
    @DEDENT = DEDENT

    constructor: (@output)->
        @stack = ['']
        @newline = true

    handleIndent: (line)->
        if not @newline
            # Indents can only occur at the start of a newline
            return line

        start = indentRegex.exec(line)[0]

        if start == line
            # Line filled with whitespace
            return ''

        # Avoid combined indentRegex & line regex extractor
        #   Needs to be indent*line* to handle whitespace lines
        #   but could cause catastrophic backtracking if feed
        #   is changed.
        line = line[start.length..]

        current = @stack[@stack.length - 1]

        # Unchanged
        if start == current
            return line

        # Indent
        else if start.startsWith current
            @stack.push start
            @output.feed INDENT
            return line

        # Dedent
        else
            while start != current and @stack.length > 1
                @output.feed DEDENT
                @stack.pop()
                current = @stack[@stack.length - 1]

            if start != current
                # Mixed indentation
                #   Wasn't the same as any indents in the stack
                @stack.push start
                @output.feed INDENT

            return line

    push: (input)->
        if typeof(input) != 'string'
            @output.feed input
            return

        lines = input.split newlineRegex
        end = lines.length

        for line, index in lines by 2
            line = @handleIndent line

            if index + 1 < end
                @output.feed line + lines[index + 1]
                @newline = true
            else if line.length != 0
                @output.feed line
                @newline = false
            else if index == 0
                @output.feed line

    feed: (input)->
        if input instanceof Array
            for element in input
                @push element
        else
            @push input

    end: ->
        while @stack.length > 1
            @output.feed DEDENT
            @stack.pop()
        @output.end()
