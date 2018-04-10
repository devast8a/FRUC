AstNode = require './astnode'

module.exports =
class AstValue extends AstNode
    constructor: (@data)->
        super()
