{expect} = require 'chai'

Grammar = require 'parser/grammar'
Matcher = require 'parser/matchers/matcher'
Any = require 'parser/matchers/any'

grammar = parent = opt = req = null

beforeEach ->
    grammar = new Grammar
    parent = new Matcher grammar
    opt = new Matcher grammar
    req = new Matcher grammar

    opt.optional = true
    opt.toString = -> 'opt'
    req.toString = -> 'req'

    return

describe 'Any.remove', ->
    it 'returns true if definition exists in any', ->
        any = new Any grammar
        matcher = any.add [req]
        expect(any.remove matcher).to.equal(true)
        return

    it 'returns false if definition does not exist in any', ->
        any = new Any grammar
        matcher = any.add [req]
        any.remove matcher

        expect(any.remove req).to.equal(false)
        expect(any.remove matcher).to.equal(false)
        return

describe 'Any.optional', ->
    it 'is true if at least one definition is optional', ->
        any = new Any grammar

        any.add [req]; expect(any.optional).to.equal(false)
        any.add [opt]; expect(any.optional).to.equal(true)
        return

    it 'is false if optional definition removed', ->
        any = new Any grammar
        any.remove any.add [opt]; expect(any.optional).to.equal(false)
        return
