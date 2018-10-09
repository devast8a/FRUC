{Return, Assign, BranchFalse, BranchTrue, Call, Jump} = require '../compiler/fir/reg/instructions'

duplicateMetadata = (metadata)->
    metadata.map (localState)->
        # Assume analysis state isn't an object
        localState.map (id)->id

mergeMetadata = (context, target, source, analyses, locals)->
    for sourceLocal, localIndex in source
        targetLocal = target[localIndex]
        local = locals[localIndex]

        for sourceState, stateIndex in sourceLocal
            targetState = targetLocal[stateIndex]
            analysis = analyses[stateIndex]
            targetLocal[stateIndex] = analysis.merge context, local, targetState, sourceState

    return target

get = (context, instruction, local, md, analyses)->
    localmd = md[local.id]
    for analysis, index in analyses
        localmd[index] = analysis.get context, instruction, local, localmd[index]
    return null

set = (context, instruction, local, md, analyses)->
    localmd = md[local.id]
    for analysis, index in analyses
        localmd[index] = analysis.set context, instruction, local, localmd[index]
    return null

lifetime = require './static/basic_lifetime'

analyze = (context, instruction, md, analyses)->
    switch instruction.constructor
        when Assign
            get context, instruction, instruction.src, md, analyses
            set context, instruction, instruction.dst, md, analyses

        when Call
            for arg in instruction.args
                get context, instruction, arg, md, analyses

            if instruction.dst?
                set context, instruction, instruction.dst, md, analyses

        when BranchTrue, BranchFalse
            get context, instruction, instruction.value, md, analyses

        # Jump does not depend on or modify the state of any locals
        when Return
            if instruction.src?
                get context, instruction, instruction.src, md, analyses

        when Jump

        else
            throw new Error "Doesn't handle #{instruction.constructor.name}"

exports.demo = (context, fn, cfg)->
    analyses = [
        lifetime
    ]

    # Create initial metadata
    md = fn.locals.map (local)->
        analyses.map (analysis)->
            analysis.declare context, local

    # List of basic blocks with no in edges
    #  There can only be one block with zero in edges, the first block
    #  as FirReg assumes functions can only have one entrypoint.
    ready = [cfg[0]]

    metadata = new Array cfg.length

    inEdges = cfg.map (node)-> new Set node.inEdges
    metadata[0] = md
    processed = cfg.map (node)-> false

    reachable = new Set

    propagate = (current)->
        # Continue topological sort
        for child in current.outEdges
            if processed[child.id]
                continue

            reachable.add child

            # Associate and merge metadata
            if metadata[child.id]?
                metadata[child.id] = mergeMetadata context, metadata[child.id], md, analyses, fn.locals
            else
                metadata[child.id] = duplicateMetadata md

            # Remove current from child.inEdges
            inEdges[child.id].delete current
            if inEdges[child.id].size <= 0
                reachable.delete child
                ready.push child
        return null

    while ready.length > 0 or reachable.size > 0
        if ready.length > 0
            current = ready.pop()
            md = metadata[current.id]
            processed[current.id] = true

            # Perform analysis on current block
            for instruction in current.instructions
                analyze context, instruction, md, analyses
            propagate current
        else
            # Choose one of the reachable nodes arbitrarily
            for current in Array.from reachable
                reachable.delete current
                stack = [[current, current.outEdges.slice 0]]

                visited = cfg.map -> false
                visited[current.id] = true

                paths = []

                while stack.length > 0
                    [block, edges] = stack[stack.length - 1]

                    if edges.length == 0
                        visited[block.id] = false
                        stack.pop()
                        continue

                    child = edges.pop()
                    if child == current
                        paths.push stack.map (entry)->entry[0]
                        continue

                    if visited[child.id]
                        continue

                    visited[child.id] = true
                    stack.push [child, child.outEdges.slice 0]

                for path in paths
                    for block in path
                        md = metadata[block.id]

                        for instruction in block.instructions
                            analyze context, instruction, md, analyses

                        for child in current.outEdges
                            # Associate and merge metadata
                            if metadata[child.id]?
                                metadata[child.id] = mergeMetadata context, metadata[child.id], md, analyses, fn.locals
                            else
                                metadata[child.id] = duplicateMetadata md

                # Remove all our inEdges
                inEdges[current.id].clear()

                ready.push current


    # We need to keep track or nodes that we could enter into that have inEdges.length > 1
    # Select one of those blocks at random, and check for all cycles (traverse graph)
    # If there are cycles, convert that cycle into an acyclic list of nodes
    # Otherwise skip and check another point
