{compile} = require 'compiler'
nameResolution = require './analysis/fang_name_resolution'
staticTypeAnalysis = require './analysis/fang_static_type'
{visit, displayAst} = require './analysis/ast_util'

# Compile fang grammar, then compile our code
fang = compile with: 'fg', inputPath: 'langs/fang/fang.fg', outputPath: 'langs/fang/index.js'
code = compile with: fang.exports, inputPath: 'langs/fang/example.fang'

################################################################################
identifierMetadata = new Map

# Gather metadata for our program
visit nameResolution, code.ast, metadata: identifierMetadata

# Perform type checking
visit staticTypeAnalysis, code.ast, metadata: identifierMetadata

displayAst code.ast
