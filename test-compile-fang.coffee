chalk = require 'chalk'
nameResolution = require './analysis/fang_name_resolution'
staticTypeAnalysis = require './analysis/fang_static_type'
{compile} = require 'compiler'
{visit, displayAst} = require './analysis/ast_util'
{FirStackFunction} = require 'compiler/fir/stack/function'
{FirRegFunction} = require 'compiler/fir/reg/function'

{FrucError} = require 'common/errors'
Source = require 'common/source'

fs = require 'fs'

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
fn = new FirStackFunction
fn.addNode null, code.ast, metadata: identifierMetadata

##### FIR STACK => FIR REGISTER
rfn = new FirRegFunction fn

for instruction in fn.terminalInstructions
    rfn.addStackInstruction instruction

# Check for labels at end of function and mark them correctly
for label in fn.labels
    if label.target == fn.instructions.length
        rfn.mark null, rfn.lookupLabel label

console.log rfn.toText()

##### STATIC ANALYSIS

{firToCfg} = require './analysis/cfg/fir_to_cfg'
cfg = firToCfg rfn

console.log cfg

# Dependent Types Demo
{demo} = require './analysis/deptype'
demo rfn, cfg


#   x = "test"
#   y = fnA(fnB(x))
#   
#   ## FirStack
#     Constant String, "Test"   # A
#   StoreLocal x                # A
#   
#         LoadLocal x           # B
#       Call newNode true 1     # B
#     Call things true 1        # C
#   StoreLocal y                # D
#   
#   ## FirReg
#   Assign Reg('x'), Constant(String, "Test")   # A
#   
#   Call fnB, [Reg('$0')], [Reg('x')]   # B
#   Call fnA, [Reg('$1')], [Reg('$0')]  # C
#   Assign Reg('y'), Reg('$1')          # D
