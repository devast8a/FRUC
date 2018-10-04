{Assign, BranchFalse, BranchTrue, Call, Jump} = require '../compiler/fir/reg/instructions'

duplicateMetadata = (metadata)->
    duplicate = new Map
    metadata.forEach (value, key)->
        duplicate.set key, new Map value
    return duplicate

isPropertyMapSame = (x, y)->
    if x == y
        return true

    if x.size != y.size
        return false

    for [key, value] in Array.from x.entries()
        if value != y.get(key)
            return false

    return true

isMetadataSame = (x, y)->
    if x == y
        return true

    if x.size != y.size
        return false

    for [key, value] in Array.from x.entries()
        if not isPropertyMapSame value, y.get(key)
            return false

    return true

exports.demo = (fn, cfg)->
    instructionMetadata = new Array fn.instructions.length

    # Create initial metadata
    md = new Map
    for local in fn.locals
        md.set local, new Map [
            ['alive', false]
        ]

    # Open block list that we need to analyze
    blocks = [
        [0, cfg[0], md]
    ]

    visitedBlocks = new Array(cfg.length).fill(false)
    blockInitialMetadata = new Array cfg.length

    while blocks.length > 0
        [index, block, md] = blocks.pop()

        # Don't visit multiple blocks twice, prevents infinite loops
        if visitedBlocks[index]
            # Check metadata is consistent with other branches
            if not isMetadataSame md, blockInitialMetadata[index]
                throw new Error "DT Error, Merged basic blocks that have differing properties"
            continue

        blockInitialMetadata[index] = md
        visitedBlocks[index] = true

        for instruction in block.instructions
            # Copy previous metadata
            md = instructionMetadata[instruction.offset] = duplicateMetadata md

            # Process instructions
            switch instruction.constructor
                when Call
                    # Check all arguments are valid
                    for argument in instruction.args
                        if not md.get(argument).get('alive')
                            throw new Error "Lifetime error, variable is dead"

                    # Mutate metadata with our return values
                    if instruction.dst?
                        md.get(instruction.dst).set('alive', true)

                when Assign
                    if !md.get(instruction.src).get('alive')
                        throw new Error "Lifetime error, variable is dead"

                    md.get(instruction.dst).set('alive', true)

                when BranchTrue, BranchFalse
                    if !md.get(instruction.value).get('alive')
                        console.log instructionMetadata
                        throw new Error "Lifetime error, variable is dead #{instruction.value.name}"

                when Jump

                else
                    throw new Error "Lifetime error, don't handle instruction #{instruction.constructor.name}"

        # Next block to look at
        for child in block.outEdges
            blocks.push [child.id, child, md]

    console.log instructionMetadata
