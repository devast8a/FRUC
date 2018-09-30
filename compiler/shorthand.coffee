Instructions = require './instructions'

# Shorthands
Assign = (dst, src)-> new Instructions.Assign dst, src

Call = (fn, dst, args)-> new Instructions.Call fn, dst, args
Return = (src)-> new Instructions.Return src

Mark = (label)-> new Instructions.Mark label
Jump = (target)-> new Instructions.Jump target
BranchFalse = (target, value)-> new Instructions.BranchFalse target, value
BranchTrue = (target, value)-> new Instructions.BranchTrue target, value

Reg = (name)-> new Instructions.Reg name
Constant = (type, value)-> new Instructions.Constant type, value
Field = (local, field)-> new Instructions.Field local, field

module.exports = {
    Assign: Assign,

    Call: Call,
    Return: Return,

    Mark: Mark,
    Jump: Jump,
    BranchFalse: BranchFalse,
    BranchTrue: BranchTrue,

    Reg: Reg,
    Constant: Constant,
    Field: Field,
}
