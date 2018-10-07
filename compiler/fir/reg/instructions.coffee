exports.OpCodes =
OpCodes = {
    Unknown:        0

    Assign:         1

    Call:           2
    Return:         3

    Jump:           4
    BranchTrue:     5
    BranchFalse:    6

    # Make sure to keep length up to date
    length:         7
}

exports.FirRegInstruction =
class FirRegInstruction
    opcode: OpCodes.Unknown

exports.Assign =
class Assign extends FirRegInstruction
    opcode: OpCodes.Assign
    constructor: (@dst, @src)-> super()

    toText: -> "Assign #{@dst.toText()} #{@src.toText()}"

################################################################################
exports.Call =
class Call extends FirRegInstruction
    opcode: OpCodes.Call
    constructor: (@function, @dst, @args)-> super()

    toText: ->
        args = (arg.toText() for arg in @args).join(", ")
        if @dst?
            return "Call #{@function} #{@dst.toText()} [#{args}]"
        return "Call #{@function} null [#{args}]"
exports.Return =
class Return extends FirRegInstruction
    opcode: OpCodes.Return
    constructor: (@src)-> super()

    toText: ->
        if @src?
            return "Return #{@src.toText()}"
        else
            return "Return null"

################################################################################
exports.Jump =
class Jump extends FirRegInstruction
    opcode: OpCodes.Jump
    constructor: (@target)-> super()

    toText: -> "Jump #{@target.toText()}"

exports.BranchTrue =
class BranchTrue extends FirRegInstruction
    opcode: OpCodes.BranchTrue
    constructor: (@target, @value)-> super()

    toText: -> "BranchTrue #{@target.toText()} #{@value.toText()}"

exports.BranchFalse =
class BranchFalse extends FirRegInstruction
    opcode: OpCodes.BranchFalse
    constructor: (@target, @value)-> super()

    toText: -> "BranchFalse #{@target.toText()} #{@value.toText()}"
