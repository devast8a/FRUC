module.exports =
class AstNode
    constructor: (@definition, @data, @start, @end)->
        if @definition.label?
            @label = @definition.label

getEnd = (data)->
    if data instanceof AstNode
        return data.end

    if data instanceof Array
        for entry in data by -1
            if (end = getEnd entry) != null
                return end

    return null

AstNode.getEnd = (data, location)->
    getEnd(data) ? location
