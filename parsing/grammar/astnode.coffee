module.exports =
class AstNode
    constructor: (@childNodes...)->
        if @init?
            @init @childNodes...

        @metadata = []
