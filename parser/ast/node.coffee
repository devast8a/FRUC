module.exports =
class Node
    constructor: (@childNodes...)->
        if @init?
            @init @childNodes...

        @metadata = []
