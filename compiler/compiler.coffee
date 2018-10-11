Grammar = require '../parser/grammar'
Parser = require '../parser'
Output = require '../output'
fs = require 'fs'
path = require 'path'

exports.compile = (options)->
    # Grammar to load
    if typeof(options.with) == 'string'
        grammar = require "../langs/#{options.with}"
    else if options.with.exports instanceof Grammar
        grammar = options.with.exports
    else if options.with instanceof Grammar
        grammar = options.with
    else
        throw new Error "with must be set to a path to a grammar, or be a grammar itself"

    # Load input
    if options.input?
        options.directory ?= ''
    else
        if options.inputPath?
            options.input = fs.readFileSync options.inputPath, 'utf8'
            options.directory ?= path.dirname(options.inputPath) + '/'
        else
            throw new Error "input or inputPath must be set"

    # Parse input
    parser = new Parser grammar
    ast = parser.parse options.input

    # No transformations available
    if not ast.outputJS?
        return {
            inputPath: options.inputPath
            input: options.input
            ast: ast
        }

    # Generate output
    output = new Output
    output.require_path = '../../'
    output.pushElement ast
    code = output.output

    if options.outputPath?
        fs.writeFileSync options.outputPath, code

    # Automatically run it
    req = (p)-> require '../' + options.directory + p
    mdl = {
        exports: {}
        input: options.input
        inputPath: options.inputPath
        output: code
        outputPath: options.outputPath
        ast: ast
    }
    try
        new Function("require", "module", "exports", code)(req, mdl, mdl.exports)
    catch e
        mdl.exception = e
    return mdl
