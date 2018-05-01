module.exports =
class Sink
    constructor: ->
        @data = []

    feed: (input)->
        if input instanceof Array
            @data = @data.concat input
        else
            @data.push input

    end: ->
