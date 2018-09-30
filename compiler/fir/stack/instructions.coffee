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

# Store <Local>
#   Pop value from stack and store into local
exports.StoreLocal =
class StoreLocal extends FirStackInstruction
    constructor: (@local)->
        super()
        @push = 0
        @pop = 1

    toText: -> "StoreLocal #{@local.name}"

# LoadField <Field>
#   Pop argument from stack, and push <Field> onto stack
exports.LoadField =
class LoadField extends FirStackInstruction
    constructor: (@field)->
        super()
        @push = 1
        @pop = 1

# StoreField <Field>
#   Pop argument from stack, pop value from stack, set <Field> to value
exports.StoreField =
class StoreField extends FirStackInstruction
    constructor: (@field)->
        super()
        @push = 0
        @pop = 2

# Constant <Type> <Value>
#   Push value onto stack
exports.Constant =
class Constant extends FirStackInstruction
    constructor: (@type, @value)->
        super()
        @push = 1
        @pop = 0

# Pop <Count>
#   Pop <Count> value off of stack
exports.Pop  =
class Pop extends FirStackInstruction
    constructor: (@count)->
        super()
        if @count < 1
            throw new Error "Pop: count must be one or greater"

        @push = 0
        @pop = @count

################################################################################

# Call <Fn> <Returns> <Argument Count>
#   If returns == true,
#       pushes one value
#   Otherwise
#       pushes no values
#   Call Fn (using those variables)
#   Push <Return Count> return values onto stack
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

# Return <Return Count>
#   End function, returning <Return Count> return values
exports.Return =
class Return extends FirStackInstruction
    constructor: (@returnCount)->
        super()
        if @returnCount < 0
            throw new Error "Return: returnCount must be zero or greater"

        @push = 0
        @pop = @returnCount

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

# BranchTrue <Target>
#   Pop argument from stack and branch to Target if == True
exports.BranchTrue =
class BranchTrue extends FirStackInstruction
    constructor: (@target)->
        super()
        @push = 0
        @pop = 1

    toText: -> "BranchTrue #{@target.name}"

# BranchFalse <Target>
#   Pop argument from stack and branch to Target if == False
exports.BranchFalse  =
class BranchFalse extends FirStackInstruction
    constructor: (@target)->
        super()
        @push = 0
        @pop = 1

    toText: -> "BranchFalse #{@target.name}"
