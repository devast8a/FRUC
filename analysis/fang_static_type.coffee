nodes = require 'langs/fang/nodes'

module.exports = staticTypeAnalysis = new Map

staticTypeAnalysis.set nodes.Call, (node, options)->
    # We need to know what function we are calling
    fn = options.metadata.get node.callable.value

    if fn == undefined
        throw new Error "You are calling a function that does not exist"

    if node.arguments.length != fn.parameters.length
        throw new Error "Too little, or too many, arguments"

    for argument, index in node.arguments
        argumentMetadata = options.metadata.get argument.value
        parameter = fn.parameters[index]

        if argumentMetadata == undefined
            throw new Error "You are using a variable that does not exist"

        if argumentMetadata.type != parameter.type.name.value
            # Assume parameter.type is TypeSimple
            throw new Error "Tried to use #{argumentMetadata.type} but expecting #{parameter.type.name.value}"
