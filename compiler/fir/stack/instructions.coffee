FirReg = require '../reg/instructions'

exports.FirStackInstruction =
class FirStackInstruction
    toText: ->
        "[#{this.constructor.name}]"

# Load <Local>
#   Push value of local onto stack
exports.LoadLocal =
class LoadLocal extends FirStackInstruction
    constructor: (@local)->
        super()
        @push = 1
        @pop = 0

    toText: -> "LoadLocal #{@local.name}"

    defineRegSemantics: (fn)->
        # TODO: Perform name resolution on register
        return fn.lookupLocal @local

# Store <Local>
#   Pop value from stack and store into local
exports.StoreLocal =
class StoreLocal extends FirStackInstruction
    constructor: (@local)->
        super()
        @push = 0
        @pop = 1

    toText: -> "StoreLocal #{@local.name}"

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
    constructor: (@field)->
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
    constructor: (@field)->
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
    constructor: (@type, @value)->
        super()
        @push = 1
        @pop = 0

    toText: -> "Constant #{@type} #{@value}"

    defineRegSemantics: (fn)->
        return new FirReg.Constant @type, @value, this

################################################################################

exports.Call =
class Call extends FirStackInstruction
    constructor: (@function, @returns, @argumentCount)->
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
            ret = fn.addLocal null, null
        else
            ret = null

        fn.addInstruction this, FirReg.Call, @function, ret, args
        return ret

exports.Return =
class Return extends FirStackInstruction
    constructor: (@returns)->
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
    constructor: (@target)->
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
    constructor: (@target)->
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
    constructor: (@target)->
        super()
        @push = 0
        @pop = 1

    toText: -> "BranchFalse #{@target.name}"

    defineRegSemantics: (fn)->
        source = fn.addStackInstruction @dependentInstructions[0]
        target = fn.lookupLabel @target
        fn.addInstruction this, FirReg.BranchFalse, target, source
        return null
