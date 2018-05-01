module.exports =
class Cache
    constructor: (@output)->
        @tokens = []

    feed: (input)->
        if input instanceof Array
            for element in input
                @tokens.push element
        else
            @tokens.push input

    flush: ->
        if @tokens.length > 0
            @output.feed @tokens
            @tokens.length = 0

    end: -> @flush()
