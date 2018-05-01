# A Stream that injects processes indentation on each newline and emits
# INDENT when the previous indentation is a subset of the new indentation
# DEDENT when the previous indentation isn't the same as the current indentation
#
# INDENT is injected AFTER a newline
# DEDENT is injected BEFORE a nwline
#
# Eg.
# A
#       B
# C
#
# Will be processed as
# A NEWLINE INDENT B DEDENT NEWLINE C
#
# The content of blank lines are ignored
#
# Note: You will probably want to run Joiner or something similar after this
#   Stream as each new line results in two feed calls.

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

        @atLineStart = true
        @lineEndsBuffer = []

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
            @flushBuffer()
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
                @flushBuffer()
                @output.feed INDENT

            return line

    flushBuffer: ->
        if @lineEndsBuffer.length > 0
            for end in @lineEndsBuffer
                @output.feed end
            @lineEndsBuffer.length = 0

    getBuffer: ->
        if @lineEndsBuffer.length > 0
            output = @lineEndsBuffer.join ''
            @lineEndsBuffer.length = 0
            return output
        return ''

    push: (input)->
        if typeof(input) != 'string'
            @flushBuffer()
            @output.feed input
            return

        lines = input.split newlineRegex
        end = lines.length

        for line, index in lines by 2
            line = @handleIndent line

            if index + 1 < end
                @flushBuffer()
                @output.feed line
                @lineEndsBuffer.push lines[index + 1]
                @newline = true
            else if line.length != 0
                @flushBuffer()
                @output.feed line
                @newline = false
            else if index == 0
                @flushBuffer()
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
        @flushBuffer()
        @output.end()
