{blame, FrucError} = require '../../common/errors'
{FirStackFunction} = require './stack/function'


class FirException extends FrucError
    constructor: (source, message, @options)->
        super source, message

exports.Type =
class Type
    constructor: (@name)->
        @stackFunctions = []
        @registerFunctions = []
        @stackResolvedFunctions = []
        @registerResolvedFunctions = []

    addNode: (source, node, options)->
        if not node.defineStackSemantics?
            throw new FirException node, "Node of type #{node.constructor.name} does not have a defineStackSemantics function", {}

        blame node, {function: this}, =>
            node.defineStackSemantics this, options

    addStackFunction: (source, name)->
        if not name?
            name = "$fn#{@stackFunctions.length}"

        fn = new FirStackFunction name
        @stackFunctions.push fn
        return fn
