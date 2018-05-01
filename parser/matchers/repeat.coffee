Any = require './any'
{Node, Value} = require '../ast'

repeat = (data)->
    data[0].data.concat data[1]

module.exports =
class Repeat extends Any
    toString: -> "Repeat(#{@rule})"

    init: (rule)->
        super()
        @rule = @definitionToMatcher rule

        separator = @getOption 'separator'
        type = @getOption 'type'

        if type == 'string'
            @tail = @add @rule,
                ([data])->
                    new Value data.data

            @repeat = @add [this, @rule],
                ([list, data])->
                    list.metadata = []
                    list.data += data.data
                    return list
        else
            if separator
                @tail = @add @rule,
                    ([data])->
                        new Node data

                @repeat = @add [this, separator, @rule],
                    ([list, data])->
                        list.metadata = []
                        list.childNodes.push data
                        return list
            else
                @tail = @add @rule,
                    ([data])->
                        new Node data

                @repeat = @add [this, @rule],
                    ([list, data])->
                        list.metadata = []
                        list.childNodes.push data
                        return list
