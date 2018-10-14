{FirStackInstruction} = require './instructions'
{blame, FrucError} = require '../../../common/errors'

chalk = require 'chalk'

class FirStackException extends FrucError
    constructor: (source, message, @options)->
        super source, message

    displayAddedInstruction: ->
        console.log ""
        console.log "While adding FirStack instruction #{chalk.cyanBright(@options.instruction.toText())}"
        fn = @options.function

        start = Math.max fn.instructions.length - 5, 0
        end = fn.instructions.length

        width = end.toString().length

        for index in [start...end]
            paddedIndex = index.toString().padStart(width, " ")
            console.log "   #{paddedIndex}: #{fn.instructions[index].toText()}"

        console.log chalk.redBright("-> #{index}") + ": #{@options.instruction.toText()}"

class Label
    constructor: (@name)->
        @target = null

class Local
    constructor: (@type, @name)->
        @isParameter = false

    toText: -> "Local(#{@name})"

exports.FirStackFunction =
class FirStackFunction
    constructor: (@name)->
        @labels = []
        @locals = []
        @instructions = []
        @stack = []

        @terminalInstructions = []
        @currentDepth = 0
        @maxDepth = 0

    addParameter: (type, name)->
        local = @addLocal type, name
        local.isParameter = true
        return local

    addLocal: (type, name)->
        local = new Local type, name
        @locals.push local
        return local

    addLabel: (name)->
        label = new Label name
        @labels.push label
        return label

    # @func addInstruction
    # Adds an instruction to the FirStack function,
    #   Sets its dependent instructions and ensures the state of the FirStack function is valid
    addInstruction: (source, constructor, args...)->
        # TODO: Keep source around
        instruction = new constructor source, args...

        ##########################
        if instruction.push != 0 and instruction.push != 1
            throw new FirStackException source, "Added an instruction that pushes less than zero elements or more than one element to the value stack.",
                function: this
                instruction: instruction

        if @currentDepth - instruction.pop < 0
            throw new FirStackException source, "Added an instruction that tries to pop more elements off the value stack than exists.",
                function: this
                instruction: instruction

        # Terminal instructions
        if instruction.push == 0
            if @currentDepth - instruction.pop > 0
                throw new FirStackException source, "Added a terminal instruction that does not consume all elements on the value stack.",
                    function: this
                    instruction: instruction

            @terminalInstructions.push instruction

        ##########################
        instruction.dependentInstructions = (@stack.pop() for i in [0...instruction.pop]).reverse()

        if instruction.push > 0
            @stack.push instruction

        @currentDepth = @currentDepth - instruction.pop + instruction.push
        instruction.offset = @instructions.length
        @instructions.push instruction

    addNode: (source, node, options)->
        if not node.defineStackSemantics?
            throw new FirStackException node, "Node of type #{node.constructor.name} does not have a defineStackSemantics function", {}

        blame node, {function: this}, =>
            node.defineStackSemantics this, options

    mark: (source, label)->
        if label.target?
            throw new FirStackException source, "The target of label #{label.name} has already been marked"

        label.target = @instructions.length

    # Converts the FirStackFunction into a textual representation of FirStack
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

        for label in @labels
            if label.target == @instructions.length
                output.push(label.name)
                output.push(": \n")

        return output.join("")
