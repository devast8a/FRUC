{Assign, BranchFalse, BranchTrue, Call, Jump, Mark, Reg} = require './shorthand'
util = require 'util'

class Label
    constructor: (@name)->

class Local
    constructor: (@type, @name)->

class FirFunction
    constructor: ->
        @high = []
        @low = []
        @locals = []

    addLocal: (type, name)->
        local = new Local type, name
        @locals.push local
        return local

    addHigh: (instruction)->
        @high.push instruction

    addLabel: (name)->
        new Label name

    addLow: (parent, instruction)->
        if instruction instanceof Array
            for i in instruction
                @addLow parent, i
        else
            instruction.id = @low.length
            @low.push [parent, instruction]

    generateLowSemantics: ->
        for instruction in @high
            instruction.generateSemantics this

Print = ->

class While
    constructor: (@condition, @body)->

    generateSemantics: (fn)->
        condition = fn.addLabel 'condition'
        end = fn.addLabel 'end'

        fn.addLow this, [
            Mark condition
            @condition
            BranchFalse end, Reg(0)

            @body
            Jump condition

            Mark end
        ]

Node = {type: "Node"}
Print = {name: "Print"}
NewNode = {name: "NewNode"}

#
# var A: Node
# if true
#   A = new(Node)
# else
#   B = new(Node)
# print(A)
#
fn = new FirFunction
A = fn.addLocal Node, 'A'
B = fn.addLocal Node, 'B'

End = fn.addLabel 'End'
FalseBranch = fn.addLabel 'FalseBranch'

fn.addLow null, [
    BranchFalse FalseBranch, true

    Call NewNode, [A], []
    Jump End

    Mark FalseBranch
    Call NewNode, [B], []

    Mark End
    Call Print, [], [A]
]

fn.generateLowSemantics()


{firToCfg} = require '../analysis/cfg/fir_to_cfg'
cfg = firToCfg fn

# Dependent Types Demo
{demo} = require '../analysis/deptype'
demo fn, cfg

console.log cfg.length
