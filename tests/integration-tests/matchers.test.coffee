{expect} = require 'chai'

Grammar = require 'parser/grammar'
Parser = require 'parser'
{Opt, Rep, OptRep} = require 'parser/grammar/helpers'

run = (input, value)->
class Tester
    constructor: (rule)->
        @grammar = new Grammar
        @grammar.root.add rule, between: null

    works: (input)->
        parser = new Parser @grammar
        parser.parse input
        return this

    fails: (input, text = "Unexpected")->
        parser = new Parser @grammar
        expect(-> parser.parse input).throw(Error, text)
        return this

################################################################################

test 'constant', ->
    new Tester 'a'
    .works 'a'
    .fails 'b'
    .fails '', "Expecting 1"
    return

test 'optional', ->
    new Tester Opt('a')
    .works 'a'
    .works ''
    .fails 'aa'
    .fails 'b'
    return

test 'repeat', ->
    new Tester Rep('a')
    .works 'a'
    .works 'aaaa'
    .fails '', "Expecting 1"
    .fails 'b'
    return

test 'optional-repeat', ->
    new Tester OptRep('a')
    .works ''
    .works 'a'
    .works 'aaaa'
    .fails 'b'
    return

################################################################################

test 'regex-constant', ->
    new Tester /a/
    .works 'a'
    .fails 'b'
    .fails '', "Expecting 1"
    return

test 'regex-charset', ->
    new Tester /[a-z]/
    .works 'h'
    .fails 'H'
    .fails '', "Expecting 1"
    return

test 'regex-repeat', ->
    new Tester /[a-z]+/
    .works 'helloworld'
    .fails 'HELLOWORLD'
    .fails '', "Expecting 1"
    return

test 'regex-repeat', ->
    new Tester /[a-z]+/
    .works 'helloworld'
    .fails 'HELLOWORLD'
    .fails '', "Expecting 1"
    return
