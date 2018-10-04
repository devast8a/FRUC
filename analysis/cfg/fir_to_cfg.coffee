{BranchFalse, BranchTrue, Jump, Mark} = require '../../compiler/fir/reg/instructions'

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

isStartOfBlock = (firFunction, instruction)->
    # TODO: Binary lookup
    for label in firFunction.labels
        if label.target == instruction.offset
            return true
    return false

class BasicBlock
    constructor: ->
        @isExit = false
        @jumpsToEnd = false

        @inEdges = []
        @outEdges = []
        @instructions = []

    pushInstruction: (instruction)->
        @instructions.push instruction

    link: (target)->
        if target.isExit
            @jumpsToEnd = true
        else
            @outEdges.push target
            target.inEdges.push this

exports.firToCfg = (firFunction)->
    blocks = []
    block = new BasicBlock

    targetToBlock = new Map
    id = 0
    block.id = id++

    # Construct basic blocks
    for instruction in firFunction.instructions
        if isJumpInstruction instruction
            block.pushInstruction instruction
            blocks.push block
            block = new BasicBlock
            block.id = id++

        else if isStartOfBlock firFunction, instruction
            # If there is a label at start of function
            #   We don't want to create a new block
            if block.instructions.length != 0
                blocks.push block
                block = new BasicBlock
                block.id = id++
                
            block.pushInstruction instruction
            
            # TODO: Be more optimal, come up with a better algo
            for label in firFunction.labels
                if label.target == instruction.offset
                    targetToBlock.set label, block

        else
            block.pushInstruction instruction
    blocks.push block


    # TODO: Be more optimal, come up with a better algo
    for label in firFunction.labels
        if label.target == firFunction.instructions.length
            targetToBlock.set label, {isExit: true}

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
