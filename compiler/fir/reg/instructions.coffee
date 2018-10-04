class Assign
    constructor: (@dst, @src)->

    toText: -> "Assign #{@dst.toText()} #{@src.toText()}"

################################################################################

class Call
    constructor: (@function, @dst, @args)->

    toText: ->
        args = (arg.toText() for arg in @args).join(", ")
        if @dst?
            return "Call #{@function} #{@dst.toText()} [#{args}]"
        return "Call #{@function} null [#{args}]"

class Return
    constructor: (@src)->

    toText: ->
        if @src?
            return "Return #{@src.toText()}"
        else
            return "Return null"

################################################################################

class Mark
    constructor: (@label)->

class Jump
    constructor: (@target)->

    toText: -> "Jump #{@target.toText()}"

class BranchTrue
    constructor: (@target, @value)->

    toText: -> "BranchTrue #{@target.toText()} #{@value.toText()}"

class BranchFalse
    constructor: (@target, @value)->

    toText: -> "BranchFalse #{@target.toText()} #{@value.toText()}"

################################################################################

class Reg
    constructor: (@name)->

class Constant
    constructor: (@type, @value)->

class Field
    constructor: (@object, @field)->

module.exports = {
    Assign: Assign,

    Call: Call,
    Return: Return,

    Mark: Mark,
    Jump: Jump,
    BranchTrue: BranchTrue,
    BranchFalse: BranchFalse,

    Reg: Reg,
    Constant: Constant,
    Field: Field,
}
