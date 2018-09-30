class Assign
    constructor: (@dst, @src)->

################################################################################

class Call
    constructor: (@fn, @dst, @args)->

class Return
    constructor: (@src)->

################################################################################

class Mark
    constructor: (@label)->

class Jump
    constructor: (@target)->

class BranchTrue
    constructor: (@target, @value)->

class BranchFalse
    constructor: (@target, @value)->

################################################################################

class Reg
    constructor: (@name)->

class Constant
    constructor: (@type, @value)->

class Field
    constructor: (@local, @field)->

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
