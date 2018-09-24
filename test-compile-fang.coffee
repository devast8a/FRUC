{compile} = require 'compiler'

compile with: 'fg', inputPath: 'langs/fang/fang.fg', outputPath: 'langs/fang/index.js'
code = compile with: 'fang', inputPath: 'langs/fang/example.fang'

console.log(code.ast)
