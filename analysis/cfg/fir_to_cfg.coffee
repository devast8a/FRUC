{BranchFalse, BranchTrue, Jump, Return, OpCodes} = require '../../compiler/fir/reg/instructions'

class BasicBlock
    constructor: (@id)->
        @returns = false
        @jumpsToEnd = false

        @inEdges = []
        @outEdges = []
        @instructions = []

    pushInstruction: (instruction)->
        @instructions.push instruction

    link: (target)->
        @outEdges.push target
        target.inEdges.push this

endsBlock = new Array(OpCodes.length).fill(false)
endsBlock[BranchFalse::opcode] = true
endsBlock[BranchTrue::opcode]  = true
endsBlock[Jump::opcode]        = true
endsBlock[Return::opcode]      = true

exports.firToCfg = (fn)->
    instructionToLabels = new Array fn.instructions.length + 1
    for label in fn.labels
        (instructionToLabels[label.target] ?= []).push label

    labelToBlock = new Array fn.labels.length

    id = 0
    
    blocks = []
    blocks.push block = new BasicBlock id++
    lastIndex = fn.instructions.length - 1

    # Construct basic blocks
    for instruction, index in fn.instructions
        if (labels = instructionToLabels[instruction.offset])?
            if block.instructions.length > 0
                blocks.push block = new BasicBlock id++

            for label in labels
                labelToBlock[label.id] = block

        if endsBlock[instruction.opcode] && index < lastIndex
            block.pushInstruction instruction
            blocks.push block = new BasicBlock id++
        else
            block.pushInstruction instruction

        if instruction.opcode == Return::opcode
            block.returns = true

    # Link blocks together
    for block, index in blocks
        instructions = block.instructions
        length = instructions.length

        if length <= 0
            continue

        instruction = instructions[length - 1]
        nextBlock = blocks[index + 1]

        switch instruction.opcode
            when BranchFalse::opcode, BranchTrue::opcode
                if nextBlock? then block.link nextBlock
                target = labelToBlock[instruction.target.id]
                block.link labelToBlock[instruction.target.id]

            when Jump::opcode
                block.link labelToBlock[instruction.target.id]

            else
                if nextBlock? then block.link nextBlock

    return blocks
