Node = require './node'

module.exports =
class Value extends Node
    constructor: (@data)->
        super()
