exports.Node  = Node  = require './node'
exports.Value = Value = require './value'
exports.List  = List  = require './list'

Node.prototype.__automatic = (definition, data, nodes)->
    names = definition.options.definition_names

    stripped = []

    @childNodes = []
    for i in [0...nodes.length]
        if data[i][0].ignoreOutput or data[i][0].parent?.ignoreOutput
            continue
        @childNodes.push nodes[i]

    for node, i in nodes
        if data[i][0].parent.label != '.between'
            stripped.push nodes[i]

    for name, i in names
        if name?
            if stripped[i] instanceof List
                this[name] = stripped[i].data
            else
                this[name] = stripped[i]

