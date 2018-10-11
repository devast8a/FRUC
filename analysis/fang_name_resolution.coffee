nodes = require '../langs/fang/nodes'

module.exports = nameResolution = new Map

Kind =
    VARIABLE: 1
    FUNCTION: 2
    CLASS: 3

nameResolution.set nodes.VariableDefinition, (node, options)->
    options.metadata.set node.name.value, {
        kind: Kind.VARIABLE
        type: node.type.value   # String, name of the type
    }

nameResolution.set nodes.Function, (node, options)->
    options.metadata.set node.name.value, {
        kind: Kind.FUNCTION
        parameters: node.parameters
    }

nameResolution.set nodes.ClassDefinition, (node, options)->
    options.metadata.set node.name.value, {
        kind: Kind.CLASS
        type: 'Type'
    }
