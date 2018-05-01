Flags = require '../grammar/flags'
{Value} = require '../ast'

Matcher = require './matcher'

{parse} = require 'regulex'

random = (seq)->
    seq[Math.floor Math.random() * seq.length]

# A matcher that matches one character from a set of many
#
# Similar to Any, but optimized for characters
module.exports =
class Charset extends Matcher
    @flags |= Flags.ADD_DIRECTLY_AS_RULE

    init: (regex)->
        @symbols = [this]
        @setRegex regex

    setRegex: (@regex)->

    test: (input)->
        if typeof(input) == 'string'
            return @regex.test input
        return false

    toString: -> "/#{@regex.source}/"

    getNodes: -> false
    generate: (tokens)->
        if not @pool?
            tree = parse @regex.source
            {chars, ranges, classes} = tree.tree[0]

            if classes.length > 0
                throw new Error 'Generating input from regex classes is not supported'

            pool = []
            for range in ranges
                start = range.charCodeAt 0
                end = range.charCodeAt 1
                for i in [start..end]
                    pool.push String.fromCharCode i
            @pool = pool.join('') + chars

        tokens.push random @pool

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
