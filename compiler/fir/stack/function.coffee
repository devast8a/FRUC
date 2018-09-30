{FirStackInstruction} = require './instructions'

class Label
    constructor: (@name)->

class Local
    constructor: (@type, @name)->

exports.FirStackFunction =
class FirStackFunction
    constructor: ->
        @locals = []
        @instructions = []

    addLocal: (type, name)->
        local = new Local type, name
        @locals.push local
        return local

    addLabel: (name)->
        new Label name

    addInstruction: (source, constructor, args...)->
        # TODO: Ensure that stack is consistent
        #   ie. Don't pop more values than exist on stack

        # TODO: Keep source around
        instruction = new constructor args...
        @instructions.push instruction

    addNode: (source, node, options)->
        if not node.defineStackSemantics?
            throw new Error "Node of type #{node.constructor.name} does not have a defineStackSemantics function"
            
        # TODO: Keep source around
        node.defineStackSemantics this, options

    mark: (source, label)->
