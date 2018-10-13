exports.Kind =
Kind =
    UNKNOWN:    0
    LOCAL:      1
    CONSTANT:   2

exports.Local =
class Local
    kind: Kind.LOCAL
    constructor: (@id, @type, @name)->
    toText: -> "Reg(#{@name})"

exports.Constant =
class Constant
    kind: Kind.CONSTANT
    constructor: (@id, @type, @value)->
    toText: -> "Constant(#{@type}, #{@value})"

class Label
    constructor: (@id, @name)->
        @target = null

    toText: -> @name

exports.FirRegFunction =
class FirRegFunction
    constructor: (@function)->
        @name = @function.name
        @constants = []
        @instructions = []
        @labels = []
        @locals = []

        @labelMap = new Map
        @localMap = new Map

    lookupLabel: (key)->
        label = @labelMap.get key
        if not label?
            label = @addLabel key.name
            @labelMap.set key, label
        return label

    lookupLocal: (key)->
        local = @localMap.get key
        if not local?
            local = @addLocal key.type, key.name
            @localMap.set key, local
        return local

    addLabel: (name)->
        label = new Label @labels.length, name
        @labels.push label
        return label

    addLocal: (type, name)->
        if not name?
            name = "$#{@locals.length}"

        local = new Local @locals.length, type, name
        @locals.push local
        return local

    addConstant: (source, type, value)->
        constant = new Constant @constants.length, type, value
        @constants.push constant
        return constant

    addInstruction: (source, constructor, args...)->
        instruction = new constructor source, args...

        instruction.offset = @instructions.length
        @instructions.push instruction

    addStackInstruction: (node, options)->
        # Create and mark a new label, if this instruction is a target
        # TODO: Switch over to a binary lookup
        for label in @function.labels
            if node.offset == label.target
                # TODO: Keep track of source
                @mark null, @lookupLabel label

        node.defineRegSemantics this, options

    mark: (source, label)->
        if label.target?
            throw new Error "The target of label #{label.name} has already been marked"

        label.target = @instructions.length

    # @func toText
    # Converts FirRegFunction into a textual representation of FirStack
    toText: ->
        output = []
        for instruction, index in @instructions
            for label in @labels
                if label.target == index
                    output.push(label.name)
                    output.push(": \n")

            output.push("\t")

            if not instruction.toText?
                throw new Error "Instruction of type #{instruction.constructor.name} does not have a toText function"

            output.push(instruction.toText())
            output.push("\n")

        for label in @labels
            if label.target == @instructions.length
                output.push(label.name)
                output.push(": \n")

        return output.join("")
