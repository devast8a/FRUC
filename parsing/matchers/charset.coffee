Flags = require '../grammar/flags'
AstNode = require '../grammar/astnode'

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
        @setRegex regex

    setRegex: (@regex)->
        @symbols = [@regex]

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

    postprocess: (data, location)->
        return new AstNode this, data[0], location, location + 1
