FirReg = require '../reg/instructions'

exports.OpCodes =
OpCodes = {
    Unknown:        0

    LoadLocal:      1
    StoreLocal:     2
    LoadField:      3
    StoreField:     4
    Constant:       5

    Call:           6
    Return:         7

    Jump:           8
    BranchTrue:     9
    BranchFalse:    10
    
    # Make sure to keep length up to date
    length:         11
}

exports.FirStackInstruction =
class FirStackInstruction
    opcode: OpCodes.Unknown

# Load <Local>
#   Push value of local onto stack
exports.LoadLocal =
class LoadLocal extends FirStackInstruction
    opcode: OpCodes.LoadLocal
    constructor: (@metadata, @local)->
        super()
        @push = 1
        @pop = 0

    toText: -> "LoadLocal #{@local}"

    defineRegSemantics: (fn)->
        # TODO: Perform name resolution on register
        return fn.lookupLocal @local

# Store <Local>
#   Pop value from stack and store into local
exports.StoreLocal =
class StoreLocal extends FirStackInstruction
    opcode: OpCodes.StoreLocal
    constructor: (@metadata, @local)->
        super()
        @push = 0
        @pop = 1

    toText: -> "StoreLocal #{@local}"

    defineRegSemantics: (fn)->
        # TODO: Perform name resolution on register
        source = fn.addStackInstruction @dependentInstructions[0]
        destination = fn.lookupLocal @local
        fn.addInstruction this, FirReg.Assign, destination, source
        return null

# LoadField <Field>
#   Pop argument from stack, and push <Field> onto stack
exports.LoadField =
class LoadField extends FirStackInstruction
    opcode: OpCodes.LoadField
    constructor: (@metadata, @field)->
        super()
        @push = 1
        @pop = 1

    toText: -> "LoadField #{@field}"

    defineRegSemantics: (fn)->
        object = fn.addStackInstruction @dependentInstructions[0]
        return new FirReg.Field object, @field

# StoreField <Field>
#   Pop argument from stack, pop value from stack, set <Field> to value
exports.StoreField =
class StoreField extends FirStackInstruction
    opcode: OpCodes.StoreField
    constructor: (@metadata, @field)->
        super()
        @push = 0
        @pop = 2

    toText: -> "StoreField #{@field}"

    defineRegSemantics: (fn)->
        object = fn.addStackInstruction @dependentInstructions[0]
        value = fn.addStackInstruction @dependentInstructions[1]
        field = new FirReg.Field object, @field
        fn.addInstruction this, FirReg.Assign, field, value
        return null

# Constant <Type> <Value>
#   Push value onto stack
# TODO: Make sure we keep track of information
exports.Constant =
class Constant extends FirStackInstruction
    opcode: OpCodes.Constant
    constructor: (@metadata, @type, @value)->
        super()
        @push = 1
        @pop = 0

    toText: -> "Constant #{@type} #{@value}"

    defineRegSemantics: (fn)->
        return fn.addConstant this, @type, @value

################################################################################

exports.Call =
class Call extends FirStackInstruction
    opcode: OpCodes.Call
    constructor: (@metadata, @function, @returns, @argumentCount)->
        super()

        if @returns
            @push = 1
        else
            @push = 0

        if @argumentCount < 0
            throw new Error "Call: argumentCount must zero or greater"
        @pop = @argumentCount

    toText: -> "Call #{@function} #{@returns} #{@argumentCount}"

    defineRegSemantics: (fn)->
        #console.log @dependentInstructions
        args = (fn.addStackInstruction i for i in @dependentInstructions)
        
        if @returns
            ret = fn.addTemporary()
        else
            ret = null

        fn.addInstruction this, FirReg.Call, @function, ret, args
        return ret

exports.Return =
class Return extends FirStackInstruction
    opcode: OpCodes.Return
    constructor: (@metadata, @returns)->
        super()
        if @returnCount < 0
            throw new Error "Return: returnCount must be zero or greater"

        @push = 0
        if @returns
            @pop = 1
        else
            @pop = 0

    toText: -> "Return #{@returns}"

    defineRegSemantics: (fn)->
        if @returns
            source = fn.addStackInstruction @dependentInstructions[0]
            fn.addInstruction this, FirReg.Return, source
        else
            fn.addInstruction this, FirReg.Return, null
        return null

################################################################################

# Jump <Target>
#   Jump to Target
exports.Jump =
class Jump extends FirStackInstruction
    opcode: OpCodes.Jump
    constructor: (@metadata, @target)->
        super()
        @push = 0
        @pop = 0

    toText: -> "Jump #{@target.name}"

    defineRegSemantics: (fn)->
        target = fn.lookupLabel @target
        fn.addInstruction this, FirReg.Jump, target
        return null

# BranchTrue <Target>
#   Pop argument from stack and branch to Target if == True
exports.BranchTrue =
class BranchTrue extends FirStackInstruction
    opcode: OpCodes.BranchTrue
    constructor: (@metadata, @target)->
        super()
        @push = 0
        @pop = 1

    toText: -> "BranchTrue #{@target.name}"

    defineRegSemantics: (fn)->
        source = fn.addStackInstruction @dependentInstructions[0]
        target = fn.lookupLabel @target
        fn.addInstruction this, FirReg.BranchTrue, target, source
        return null

# BranchFalse <Target>
#   Pop argument from stack and branch to Target if == False
exports.BranchFalse  =
class BranchFalse extends FirStackInstruction
    opcode: OpCodes.BranchFalse
    constructor: (@metadata, @target)->
        super()
        @push = 0
        @pop = 1

    toText: -> "BranchFalse #{@target.name}"

    defineRegSemantics: (fn)->
        source = fn.addStackInstruction @dependentInstructions[0]
        target = fn.lookupLabel @target
        fn.addInstruction this, FirReg.BranchFalse, target, source
        return null
