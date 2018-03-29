Flags = require './flags'
Matcher = require './matcher'

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
