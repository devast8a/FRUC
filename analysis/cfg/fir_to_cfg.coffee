{BranchFalse, BranchTrue, Jump, Mark} = require '../../compiler/instructions'

jumpInstructions = [
    BranchFalse
    BranchTrue
    Jump
]

isJumpInstruction = (instruction)->
    for type in jumpInstructions
        if instruction instanceof type
            return true
    return false

class BasicBlock
    constructor: ->
        @inEdges = []
        @outEdges = []
        @instructions = []

    pushInstruction: (instruction)->
        @instructions.push instruction

    link: (target)->
        @outEdges.push target
        target.inEdges.push this

exports.firToCfg = (firFunction)->
    blocks = []
    block = new BasicBlock

    targetToBlock = new Map
    id = 0
    block.id = id++

    # Construct basic blocks
    for [high, instruction] in firFunction.low
        if isJumpInstruction instruction
            block.pushInstruction instruction
            blocks.push block
            block = new BasicBlock
            block.id = id++

        else if instruction instanceof Mark
            # If there is a jump/mark or a mark at start of file
            #   We don't want to create a new block
            if block.instructions.length != 0
                blocks.push block
                block = new BasicBlock
                block.id = id++
                
            block.pushInstruction instruction
            targetToBlock.set instruction.label, block

        else
            block.pushInstruction instruction
    blocks.push block

    # Link basic blocks together
    for block, index in blocks
        instruction = block.instructions[block.instructions.length - 1]
        nextBlock = blocks[index + 1]
        
        if instruction instanceof Jump
            targetBlock = targetToBlock.get instruction.target
            block.link targetBlock

        else if (instruction instanceof BranchTrue) or (instruction instanceof BranchFalse)
            targetBlock = targetToBlock.get instruction.target
            if nextBlock? then block.link nextBlock
            block.link targetBlock

        else
            if nextBlock? then block.link nextBlock

    return blocks
