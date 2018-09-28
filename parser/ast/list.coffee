Value = require './value'

module.exports =
class List extends Value
    constructor: (@data)->
        super()
        @childNodes = @data
