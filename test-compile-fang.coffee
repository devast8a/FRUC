chalk = require 'chalk'
nameResolution = require './analysis/fang_name_resolution'
staticTypeAnalysis = require './analysis/fang_static_type'
{compile} = require './compiler'
{visit, displayAst} = require './analysis/ast_util'

{FirStackFunction} = require './compiler/fir/stack'
{FirRegFunction} = require './compiler/fir/reg'
{FirRegResolvedFunction} = require './compiler/fir/reg-r'

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


{Instructions: Reg} = require './compiler/fir/reg'
{Instructions: RegR} = require './compiler/fir/reg-r'
{Kind} = require './compiler/fir/reg/function'

handle ->
    context = new Context

    rep = (text, length)->
        return new Array(length).fill(text).join('')

    # Compile fang grammar, then compile our code
    fang = compile with: 'fg', inputPath: 'langs/fang/fang.fg', outputPath: 'langs/fang/index.js'

    ########## Read File / Parsing / Parse Tree Annotation
    code = compile with: fang.exports, inputPath: 'langs/fang/example.fang'

    ########## Intermediate Representation Generation
    type = new Type
    type.addNode null, code.ast

    console.log code.input

    ########## Stack to Register Conversion
    for fn in type.stackFunctions
        rfn = new FirRegFunction fn
        type.registerFunctions.push rfn

        for instruction in fn.terminalInstructions
            rfn.addStackInstruction instruction

        # Check for labels at end of function and mark them correctly
        for label in fn.labels
            if label.target == fn.instructions.length
                rfn.mark null, rfn.lookupLabel label

        console.log rfn.name
        console.log fn.toText()
        console.log "        ----"
        console.log rfn.toText()

    ########## Symbol Resolution [R]
    resolve = (context, input)->
        switch input.kind
            when Kind.IDENTIFIER
                local = context.scope.get input.name
                if not local?
                    local = context.resolved.addLocal "UNTYPED", input.name
                    context.scope.set input.name, local
                return local

            when Kind.CONSTANT
                return context.resolved.addConstant input, "UNTYPED", input.value

        throw new Error "Can't handle input of #{input}"

    for unresolved in type.registerFunctions
        resolved = new FirRegResolvedFunction unresolved

        # Maps names to locals
        scope = new Map

        ctx =
            resolved: resolved
            unresolved: unresolved
            scope: scope

        # If there is a local with the same name as the identifier
        # Then we resolve the identifier to that local
        # Go over all instructions
        for instruction in unresolved.instructions
            switch instruction.opcode
                when Reg.Assign::opcode
                    src = resolve ctx, instruction.src
                    dst = resolve ctx, instruction.dst

                    resolved.addInstruction instruction, RegR.Assign, dst, src

                when Reg.Call::opcode
                    fn = resolve ctx, instruction.function
                    args = for arg in instruction.args then resolve ctx, arg
                    if dst? then dst = resolve ctx, instruction.dst

                    resolved.addInstruction instruction, RegR.Call, fn, dst, args

                when Reg.Return::opcode
                    if src? then src = resolve ctx, instruction.src

                    resolved.addInstruction instruction, RegR.Return, src

                when Reg.Jump::opcode
                    resolved.addInstruction instruction, RegR.Jump, instruction.target

                when Reg.BranchTrue::opcode
                    value = resolve ctx, instruction.value

                    resolved.addInstruction instruction, RegR.BranchTrue, instruction.target, value

                when Reg.BranchFalse::opcode
                    value = resolve ctx, instruction.value

                    resolved.addInstruction instruction, RegR.BranchFalse, instruction.target, value

        type.registerResolvedFunctions.push resolved
        console.log resolved.toText()
    ########## Resolved Symbol Code Rewrite

    ########## Intra-unit Pluggable Static Analysis
    for fn in type.registerResolvedFunctions
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
