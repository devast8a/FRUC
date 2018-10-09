module.exports = (graph)->
    nodes = []
    for node in graph
        if node.inEdges.length == 0
            nodes.push node
        else
            node._inEdges = new Set node.inEdges

    sorted = []
    while nodes.length > 0
        node = nodes.pop()
        sorted.push node
        
        for child in node.outEdges
            child._inEdges.delete node

            if child._inEdges.size == 0
                nodes.push child

    return sorted
