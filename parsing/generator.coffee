class Node
    constructor: (@rule)->
        @inEdges = []
        @outEdges = []

random = (arr)->
    arr[Math.floor Math.random() * arr.length]

shuffle = (array)->
    array = array.slice 0
    i = array.length
    while --i > 0
        j = Math.floor Math.random() * (i + 1)
        temp = array[j]
        array[j] = array[i]
        array[i] = temp
    return array

count = (array, element)->
    c = 0
    for i in array
        if i == element
            c++
    return c

find = (path, parents, parent)->
    path.push parent
    parents.push parent

    ns = shuffle parent.getNodes()

    if ns.length == 0
        return false

    for nodes in ns
        noroute = false
        temp = []

        for node in nodes
            c = count parents, node
            r = Math.floor Math.random() * 200
            #console.log c, r
            if c > r
                noroute = true
                break
            noroute or= find temp, parents, node

        if not noroute
            for t in temp
                path.push t
            parents.pop()
            return false

    parents.pop()
    return true

module.exports =
class Generator
    constructor: (@grammar)->

    generate: ->
        root = @grammar.root

        path = []
        find path, [], root

        output = []
        for n in path
            n.generate output

        return output
