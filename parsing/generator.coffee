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

    nodes = parent.getNodes()

    if nodes == false
        return false

    ns = shuffle nodes

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

class TokenStream
    constructor: ->
        @tokens = []
        @text = []

    push: (token)->
        if typeof(token) == 'string'
            @text.push token
        else
            @pushText()
            @tokens.push token

    pushText: ->
        if @text.length > 0
            @tokens.push @text.join ''

    getTokens: ->
        @pushText()
        return @tokens

module.exports =
class Generator
    constructor: (@grammar)->

    generate: ->
        root = @grammar.root

        path = []
        find path, [], root

        tokens = new TokenStream
        for n in path
            n.generate tokens

        return tokens.getTokens()
