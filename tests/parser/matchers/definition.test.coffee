{expect} = require 'chai'

Grammar = require '../../../parser/grammar'
Matcher = require '../../../parser/matchers/matcher'
Definition = require '../../../parser/matchers/definition'
{Optional} = Definition

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

mk = (def)->
    new Definition grammar, [def], {parent: parent}

describe 'Definition.optional', ->
    fn = (def)-> mk(def).optional

    it 'is true if all matchers in definition are optional', ->
        expect(fn [req]).to.equal(false)
        expect(fn [opt]).to.equal(true)
        expect(fn [opt, req]).to.equal(false)
        expect(fn [req, opt]).to.equal(false)
        expect(fn [opt, opt]).to.equal(true)
        return

describe 'Definition.symbols', ->
    fn = (def)-> mk(def).symbols

    it 'is generated correctly', ->
        r = req.name
        o = opt.name
        b = grammar.between.name

        expect(fn [req]).deep.equal([r])
        expect(fn [req, req]).deep.equal([r, b, r])
        return
    
    it 'replaces optional matchers with Optional and sets direction correctly', ->
        symbols = fn [req, opt]
        expect(symbols.length).to.equal(2)
        expect(symbols[1] instanceof Optional)
        expect(symbols[1].direction == Optional.BACK)

        symbols = fn [opt, req]
        expect(symbols.length).to.equal(2)
        expect(symbols[0] instanceof Optional)
        expect(symbols[0].direction == Optional.FRONT)

        symbols = fn [opt, req, opt]
        expect(symbols.length).to.equal(3)
        expect(symbols[1] instanceof Optional)
        expect(symbols[1].direction == Optional.MIDDLE)
        return
