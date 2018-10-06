{Assign, BranchFalse, BranchTrue, Call, Jump} = require '../compiler/fir/reg/instructions'

duplicateMetadata = (metadata)->
    metadata.map (localState)->
        # Assume analysis state isn't an object
        localState.map (id)->id

mergeMetadata = (target, source, analyses, locals)->
    for sourceLocal, localIndex in source
        targetLocal = target[localIndex]
        local = locals[localIndex]

        for sourceState, stateIndex in sourceLocal
            targetState = targetLocal[stateIndex]
            analysis = analyses[stateIndex]
            targetLocal[stateIndex] = analysis.merge local, targetState, sourceState

    return target

lifetime =
    ALIVE: false
    DEAD: true

    declared: (variable)-> lifetime.DEAD
    merge: (variable, target, source)-> target or source
    set: (instruction, variable, state)-> lifetime.ALIVE
    get: (instruction, variable, state)->
        if state != lifetime.ALIVE
            throw new Error "Lifetime error"

get = (instruction, local, md, analyses)->
    localmd = md[local.id]
    for analysis, index in analyses
        analysis.get instruction, local, localmd[index]
    return null

set = (instruction, local, md, analyses)->
    localmd = md[local.id]
    for analysis, index in analyses
        localmd[index] = analysis.set instruction, local, localmd[index]
    return null

exports.demo = (fn, cfg)->
    analyses = [
        lifetime
    ]

    # Create initial metadata
    md = fn.locals.map (local)->
        analyses.map (analysis)->
            analysis.declared local

    # List of basic blocks with no in edges
    #  There can only be one block with zero in edges, the first block
    #  As FirReg assumes functions can only have one entrypoint (and it's
    #  always the first)
    blocks = [cfg[0]]

    metadata = new Array(cfg.length)
    metadata[0] = md

    inEdges = cfg.map (node)-> new Set node.inEdges

    while blocks.length > 0 #or graph.length > 0
        current = blocks.pop()
        md = metadata[current.id]

        # Perform analysis on current block
        for instruction in current.instructions
            switch instruction.constructor
                when Assign
                    get instruction, instruction.src, md, analyses
                    set instruction, instruction.dst, md, analyses

                when Call
                    for arg in instruction.args
                        get instruction, arg, md, analyses
                    
                    if instruction.dst?
                        set instruction, instruction.dst, md, analyses

                when BranchTrue, BranchFalse
                    get instruction, instruction.value, md, analyses

                # Jump does not depend on or modify the state of any locals
                when Jump

                else
                    throw new Error "Doesn't handle #{instruction.constructor.name}"

        for child in current.outEdges
            # Associate and merge metadata
            if metadata[child.id]?
                # Otherwise we want to merge metadata with the previously associated metadata
                metadata[child.id] = mergeMetadata metadata[child.id], md, analyses, fn.locals
            else
                metadata[child.id] = duplicateMetadata md

            # Remove current from child.inEdges
            inEdges[child.id].delete current
            if inEdges[child.id].size <= 0
                blocks.push child
