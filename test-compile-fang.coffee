chalk = require 'chalk'
nameResolution = require './analysis/fang_name_resolution'
staticTypeAnalysis = require './analysis/fang_static_type'
{compile} = require './compiler'
{visit, displayAst} = require './analysis/ast_util'

{FirStackFunction} = require './compiler/fir/stack/function'
{Return} = require './compiler/fir/stack/instructions'
{FirRegFunction} = require './compiler/fir/reg/function'

{handle, FrucError} = require './common/errors'
Source = require './common/source'

C = require './targets/c'

fs = require 'fs'

{Context} = require './common/context'
{Type} = require './compiler/fir/type'
{firToCfg} = require './analysis/cfg/fir_to_cfg'
{demo} = require './analysis/deptype'



# Fang needs to perform the following
#   AstNameResolution
#   FirStack
#   FirReg


handle ->
    rep = (text, length)->
        return new Array(length).fill(text).join('')

    # Compile fang grammar, then compile our code
    fang = compile with: 'fg', inputPath: 'langs/fang/fang.fg', outputPath: 'langs/fang/index.js'

    # Read File / Parsing / Parse Tree Annotation
    code = compile with: fang.exports, inputPath: 'langs/fang/example.fang'

    ################################################################################
    identifierMetadata = new Map

    ########## NAME RESOLUTION
    visit nameResolution, code.ast, metadata: identifierMetadata

    ########## Intermediate Representation Generation
    type = new Type
    type.addNode null, code.ast, metadata: identifierMetadata

    # Add final return
    # fn.addInstruction null, Return

    ########## Stack to Register Conversion
    type.registerFunctions = []
    for fn in type.stackFunctions
        rfn = new FirRegFunction fn
        type.registerFunctions.push rfn

        for instruction in fn.terminalInstructions
            rfn.addStackInstruction instruction

        # Check for labels at end of function and mark them correctly
        for label in fn.labels
            if label.target == fn.instructions.length
                rfn.mark null, rfn.lookupLabel label

    context = new Context

    ########## Symbol Resolution [R]
    ########## Resolved Symbol Code Rewrite

    ########## Intra-unit Pluggable Static Analysis
    for fn in type.registerFunctions
        cfg = firToCfg fn

        # Dependent Types Demo
        demo context, fn, cfg

        if context.errors.length > 0
            for e in context.errors
                console.log "%s %s: %s", chalk.black.bgRedBright("  COMPILER ERROR  "), e.constructor.name, e.message

                console.log e.source

                console.log ""
                console.log "=== Stack Trace ==="
                console.log e.stack
            return

    ########## Inter-unit Pluggable Static Analysis

    ########## Target Generation
    code = C.output type
    console.log code

    #fs.writeFileSync 'test.c', code
