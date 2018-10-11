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



# Fang needs to perform the following
#   AstNameResolution
#   FirStack
#   FirReg


handle ->
    rep = (text, length)->
        return new Array(length).fill(text).join('')

    # Compile fang grammar, then compile our code
    fang = compile with: 'fg', inputPath: 'langs/fang/fang.fg', outputPath: 'langs/fang/index.js'
    code = compile with: fang.exports, inputPath: 'langs/fang/example.fang'

    ################################################################################
    identifierMetadata = new Map

    ##### NAME RESOLUTION
    visit nameResolution, code.ast, metadata: identifierMetadata

    ##### AST => FIR STACK
    type = new Type
    type.addNode null, code.ast, metadata: identifierMetadata

    # Add final return
    #fn.addInstruction null, Return

    ##### FIR STACK => FIR REGISTER
    rfn = new FirRegFunction fn

    for instruction in fn.terminalInstructions
        rfn.addStackInstruction instruction

    # Check for labels at end of function and mark them correctly
    for label in fn.labels
        if label.target == fn.instructions.length
            rfn.mark null, rfn.lookupLabel label

    # console.log rfn.toText()

    ##### STATIC ANALYSIS

    {firToCfg} = require './analysis/cfg/fir_to_cfg'
    cfg = firToCfg rfn

    #console.log "#####################"
    #for block in cfg
    #    console.log "Block: #{block.id}"
    #    for instruction in block.instructions
    #        console.log instruction.toText()
    #    for edges in block.outEdges
    #        console.log " => #{edges.id}"
    #    console.log ""

    # Dependent Types Demo
    {demo} = require './analysis/deptype'

    context = new Context

    demo context, rfn, cfg

    if context.errors.length > 0
        for e in context.errors
            console.log "%s %s: %s", chalk.black.bgRedBright("  COMPILER ERROR  "), e.constructor.name, e.message

            console.log e.source

            console.log ""
            console.log "=== Stack Trace ==="
            console.log e.stack
        return

    code = C.output rfn
    console.log code

    #fs.writeFileSync 'test.c', code
