{expect} = require 'chai'
compiler = require 'compiler'

test 'fg can be compiled', ->
    compiler.compile with: 'fg', inputPath: 'grammars/fg/fg.fg'
    return

test 'fg can compile fg', ->
    fg1 = compiler.compile with: 'fg', inputPath: 'grammars/fg/fg.fg'
    fg2 = compiler.compile with: fg1, inputPath: 'grammars/fg/fg.fg'
    fg3 = compiler.compile with: fg2, inputPath: 'grammars/fg/fg.fg'

    expect(fg1.output).to.equal(fg2.output)
    expect(fg2.output).to.equal(fg3.output)
    return
