nodes = require 'langs/fang/nodes'

module.exports = nameResolution = new Map

nameResolution.set nodes.VariableDefinition, (node, options)->
    options.metadata.set node.name.value, {
        isFunction: false
        isVariable: true
        type: node.type.value
    }

nameResolution.set nodes.Function, (node, options)->
    options.metadata.set node.name.value, {
        isFunction: true
        isVariable: false
        parameters: node.parameters
    }
