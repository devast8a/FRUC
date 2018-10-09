chalk = require 'chalk'
fmt = require 'fmt'

rep = (text, length)->
    return "".padEnd(length, text)

exports.blame =
blame = (source, options, fn)->
    try
        fn()
    catch e
        if e instanceof FrucError
            throw e
        else
            throw new FrucWrappedException source, "#{e.constructor.name}: #{e.message}",
                function: this
                exception: e

exports.handle =
handle = (fn)->
    try
        fn()
    catch e
        if not (e instanceof FrucError)
            throw e

        console.log "%s %s: %s", chalk.black.bgRedBright("  COMPILER ERROR  "), e.constructor.name, e.message


        console.log e.source

        console.log ""
        console.log "=== Stack Trace ==="
        console.log e.stack

exports.FrucError =
class FrucError extends Error
    constructor: (@source, message)->
        super message

        # Maintains proper stack trace for where our error was thrown (only available on V8)
        if Error.captureStackTrace
            Error.captureStackTrace this, @constructor

        @name = @constructor.name

    createPointer: (prefix, {start, end})->
        whitespace = rep ' ', prefix + start.column
        squiggle = rep '~', end.column - start.column - 2 # -2 because of the arrows
        return "#{whitespace}^#{squiggle}^"

    displaySource: (source, locations, options)->
        {start, end} = locations
        startLine = Math.max 0, start.line - 3
        endLine = end.line + 1

        width = endLine.toString().length
        lines = source.linesToList startLine, endLine

        # Strip blank lines from start and end
        stripStart = 0
        for [line, content] in lines
            if content == ''
                stripStart++
            else
                break

        stripEnd = lines.length
        for [line, content] in lines by -1
            if content == ''
                stripEnd--
            else
                break

        for [line, content] in lines[stripStart..stripEnd]
            lineText = (line + 1).toString().padStart(width, " ")

            if line == start.line
                console.log chalk.redBright("-> #{lineText}") + ": #{content}"
                console.log chalk.redBright(@createPointer(width + 5, locations))
            else if line >= start.line and line <= end.line
                console.log chalk.redBright("-> #{lineText}") + ": #{content}"
            else
                console.log "   #{lineText}: #{content}"

class FrucWrappedException extends FrucError
    constructor: (@source, message, @options)->
        super message
        this.stack = @options.exception.stack
