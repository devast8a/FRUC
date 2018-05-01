module.exports =
class Joiner
    constructor: (@output)->
        @text = []

    feed: (input)->
        if input instanceof Array
            for element in input
                @push element
        else
            @push input

    push: (input)->
        if typeof(input) == 'string'
            @text.push input
        else
            @pushText()
            @output.feed input

    pushText: ->
        if @text.length > 0
            @output.feed @text.join ''
            @text.length = 0

    end: ->
        @pushText()
