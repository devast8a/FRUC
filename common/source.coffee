LineMap = require './linemap'

module.exports =
class Source extends LineMap
    constructor: (map, @source)->
        super map
        @length = @source.length
        @lines = map.length

    lineToString: (line)->
        mapping = @lineToMapping line
        return @source[mapping.start...mapping.end]

    linesToString: (start, end)->
        if end - 1 < start
            return ""

        startMapping = @lineToMapping start
        endMapping = @lineToMapping (end - 1)
        return @source[startMapping.start...endMapping.end]

    linesToList: (start, end)->
        return ([line, @lineToString line] for line in [start...end])

    @fromText = (source)->
        return new Source LineMap.fromText(source).mappings, source
