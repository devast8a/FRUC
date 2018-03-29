Flags = require './flags'
Matcher = require './matcher'

random = (seq)->
    seq[Math.floor Math.random() * seq.length]

# A matcher that matches one character from a set of many
#
# Similar to Any, but optimized for characters
module.exports =
class Charset extends Matcher
    @flags |= Flags.ADD_DIRECTLY_AS_RULE

    init: (options, regex)->
        @setRegex regex

    setRegex: (@regex)->
        @symbols = [@regex]

    toString: -> "/#{@regex.source}/"

    getNodes: -> false
    generate: (tokens)->
        source = @regex.source
        source = source[1..-2]
        source = source.replace /\\(.)/g, (a, b)->b
        tokens.push random source
