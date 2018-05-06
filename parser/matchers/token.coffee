{Value} = require '../ast'

Matcher = require './matcher'

module.exports =
class Token extends Matcher
    @flags |= Matcher.Flags.ADD_DIRECTLY_AS_RULE

    init: (@token)->
        @symbols = [this]

    test: (token)->
        token.constructor == Object and token.token == @token

    toString: -> "%#{@token}"

    getNodes: -> false
    generate: (tokens)-> tokens.push {name: @token}
    ignoreOutput: true

    preprocess: (data, location, map)->
        data = data[0]

        for entry in map
            if location < entry.end
                start_line = entry.line
                start_column = location - entry.start
                break

        end = location + data.length
        for entry in map
            if end < entry.end
                end_line = entry.line
                end_column = end - entry.start
                break

        node = new Value data
        node.metadata.push {
            definition: this
            start: {
                offset: location
                line: start_line + 1
                column: start_column + 1
            }
            end: {
                offset: end
                line: end_line + 1
                column: end_column + 1
            }
        }
        return node
