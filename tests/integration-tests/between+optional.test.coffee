{expect} = require 'chai'

Grammar = require 'parser/grammar'
Parser = require 'parser'
{Opt, Rep, OptRep} = require 'parser/grammar/helpers'

class Tester
    constructor: (rule)->
        @grammar = new Grammar
        @grammar.between.add '_'
        @grammar.root.add rule

    ok: (input)->
        parser = new Parser @grammar
        parser.parse input
        return this

    throws: (input, text = "Unexpected")->
        parser = new Parser @grammar
        expect(-> parser.parse input).throw(Error, text)
        return this

tester = (rule)-> new Tester(rule)

################################################################################

it 'inserts into sequences', ->
    tester ['A', 'B']
    .ok 'A_B'
    .throws 'AB'
    .throws 'A__B'

    tester ['A', 'B', 'C']
    .ok 'A_B_C'
    .throws 'ABC'
    return

it 'handles ending optional components', ->
    tester ['A', Opt('B'), Opt('C')]
    .ok 'A'
    .ok 'A_B'
    .ok 'A_C'
    .throws 'A_', 'Expecting 1'
    .throws 'A__C'
    return

it 'handles beginning optional components', ->
    tester [Opt('A'), Opt('B'), 'C']
    .ok 'A_C'
    .ok 'B_C'
    .ok 'A_B_C'
    .throws '_C'
    .throws 'A__C'
    return

it 'handles middle optional components', ->
    tester ['A', Opt('B'), 'C']
    .ok 'A_C'
    .ok 'A_B_C'
    .throws 'A__C'
    .throws '_C'
    .throws 'A_', 'Expecting 1'
    return

it 'handles all optional components', ->
    tester [Opt('A'), Opt('B'), Opt('C')]
    .ok 'A'
    .ok 'B'
    .ok 'C'
    return
