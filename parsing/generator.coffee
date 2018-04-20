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
            @text = []

    getTokens: ->
        @pushText()
        return @tokens

Rule = require './matchers/rule'
AstValue = require './grammar/astvalue'

unparse = (grammar, ast, matcher, tokens)->
    index = 0
    for child in matcher.matchers
        if child instanceof Rule
            if not child.ignoreOutput
                unparse_rule grammar, ast.childNodes[index++], child, tokens
        else
            child.unparse tokens

unparse_rule = (grammar, ast, _, tokens)->
    if ast instanceof AstValue
        tokens.push ast.data
    else
        for matcher in grammar.matchers
            if ast.constructor == matcher.options.astnode
                unparse grammar, ast, matcher, tokens
                break

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

    unparse: (ast)->
        tokens = new TokenStream

        for node in ast.childNodes
            # Find target rule to unparse
            for matcher in @grammar.matchers
                if node.constructor == matcher.options.astnode
                    # Figure out which parts need to be unparsed
                    unparse @grammar, node, matcher, tokens
                    break
            tokens.push ';\n'

        return tokens.getTokens()
