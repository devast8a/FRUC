compiler = require 'compiler'

fg1 = compiler.compile
    with: 'fg'
    inputPath: 'langs/fg/fg.fg'
    outputPath: 'langs/fg/fg.fg.js'

fg2 = compiler.compile
    with: fg1
    inputPath: 'langs/fg/fg.fg'
    outputPath: 'langs/fg/fg.fg.js'

fg3 = compiler.compile
    with: fg2
    inputPath: 'langs/fg/fg.fg'
    outputPath: 'langs/fg/fg.fg.js'

if (fg1.output != fg2.output) or (fg2.output != fg3.output)
    console.log "fg error"
    return
