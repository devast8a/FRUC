{FirStackInstruction} = require './instructions'

class Label
    constructor: (@name)->
        @target = null

class Local
    constructor: (@type, @name)->

exports.FirStackFunction =
class FirStackFunction
    constructor: ->
        @labels = []
        @locals = []
        @instructions = []

    addLocal: (type, name)->
        local = new Local type, name
        @locals.push local
        return local

    addLabel: (name)->
        label = new Label name
        @labels.push label
        return label

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
        if label.target?
            throw new Error "The label #{label.name} has already been marked"

        label.target = @instructions.length

    toText: ->
        output = []
        for instruction, index in @instructions
            for label in @labels
                if label.target == index
                    output.push(label.name)
                    output.push(": \n")

            output.push("\t")
            output.push(instruction.toText())
            output.push("\n")

        return output.join("")
