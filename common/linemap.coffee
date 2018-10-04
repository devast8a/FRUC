module.exports =
class LineMap
    constructor: (@mappings)->

    lineToMapping: (line)->
        return @mappings[line]

    offsetToMapping: (offset)->
        # TODO: Switch to a binary lookup
        for mapping, index in @mappings
            if offset < mapping.lineEnd
                return mapping
        throw new Error "Offset is out of bounds #{offset}"

    offsetToLine: (offset)->
        mapping = @offsetToMapping offset
        return mapping.line

    offsetToColumn: (offset)->
        mapping = @offsetToMapping offset
        return offset - mapping.start

    offsetToLineColumn: (offset)->
        mapping = @offsetToMapping offset
        return {
            line: mapping.line
            column: offset - mapping.start
        }

    offsetToInfo: (offset)->
        mapping = @offsetToMapping offset
        return {
            offset: offset
            line: mapping.line
            column: offset - mapping.start
        }

    lineColumnToOffset: ({line, column})->
        mapping = @lineToMapping line
        return mapping.start + column

    @fromText = (source)->
        regex = /(?:\r\n|\r|\n)/g
        map = []

        line = 0
        prev = 0

        while match = regex.exec source
            map.push
                start: prev
                end: regex.lastIndex - match[0].length
                lineEnd: regex.lastIndex
                line: line++
                data: match[0]
            prev = regex.lastIndex

        map.push
            start: prev
            end: source.length + 1
            lineEnd: source.length + 1
            line: line++

        return new LineMap map
