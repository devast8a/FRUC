module.exports =
class Node
    constructor: (definition, data, nodes)->
        @metadata = []
        @metadata.definition = definition

        @__process definition, data, nodes
        if @init?
            @init @childNodes...

    __process: (definition, data, nodes)->
        if data?
            @childNodes = []
            for i in [0...nodes.length]
                if data[i].definition.ignoreOutput or data[i].definition.parent?.ignoreOutput
                    continue
                @childNodes.push nodes[i]
        else
            @childNodes = nodes
