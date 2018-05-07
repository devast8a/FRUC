{expect} = require 'chai'

Grammar = require 'parser/grammar'
Parser = require 'parser'
{Opt, Rep, OptRep} = require 'parser/grammar/helpers'

class Tester
    constructor: (rule)->
        @grammar = new Grammar
        @grammar.root.add rule, between: null

    ok: (input)->
        parser = new Parser @grammar
        parser.parse input
        return this

    throws: (input, text = "Unexpected")->
        parser = new Parser @grammar
        expect(-> parser.parse input).throw(Error, text)
        return this

################################################################################

test 'constant', ->
    new Tester 'a'
    .ok 'a'
    .throws 'b'
    .throws '', "Expecting 1"
    return

test 'optional', ->
    new Tester Opt('a')
    .ok 'a'
    .ok ''
    .throws 'aa'
    .throws 'b'
    return

test 'repeat', ->
    new Tester Rep('a')
    .ok 'a'
    .ok 'aaaa'
    .throws '', "Expecting 1"
    .throws 'b'
    return

test 'optional-repeat', ->
    new Tester OptRep('a')
    .ok ''
    .ok 'a'
    .ok 'aaaa'
    .throws 'b'
    return

################################################################################

test 'regex-constant', ->
    new Tester /a/
    .ok 'a'
    .throws 'b'
    .throws '', "Expecting 1"
    return

test 'regex-charset', ->
    new Tester /[a-z]/
    .ok 'h'
    .throws 'H'
    .throws '', "Expecting 1"
    return

test 'regex-repeat', ->
    new Tester /[a-z]+/
    .ok 'helloworld'
    .throws 'HELLOWORLD'
    .throws '', "Expecting 1"
    return

test 'regex-repeat', ->
    new Tester /[a-z]+/
    .ok 'helloworld'
    .throws 'HELLOWORLD'
    .throws '', "Expecting 1"
    return
