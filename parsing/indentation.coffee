INDENT = {name: 'INDENT'}
DEDENT = {name: 'DEDENT'}

class TokenStream
    constructor: ->
        @tokens = []
        @text = []

    push: (token)->
        if typeof(token) == 'string'
            @text.push token
        else
            @pushText()
            @tokens.push token

    pushText: ->
        if @text.length > 0
            @tokens.push @text.join ''
            @text = []

    getTokens: ->
        @pushText()
        return @tokens

indent = /^(\s*)([^\n]+)/
class IndentationTokenizer
    feed: (input)->
        # Read each line separately
        input = input.split /\n/
        stack = ['']
        output = new TokenStream

        for line in input
            [_, start, line] = indent.exec line

            if start == stack[0]
                output.push line
            else if start.startsWith stack[0]
                stack.unshift start
                output.push INDENT
                output.push line
            else
                while start != stack[0] and stack.length > 1
                    output.push DEDENT
                    stack.shift()
                if start != stack[0]
                    output.push INDENT
                    stack.unshift start
                output.push line

        while stack.length > 1
            output.push DEDENT
            stack.shift()

        return output.getTokens()

tokenizer = new IndentationTokenizer
o = tokenizer.feed """
def main ->
    if things
"""

console.log o
