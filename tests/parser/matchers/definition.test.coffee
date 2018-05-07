{expect} = require 'chai'

Grammar = require 'parser/grammar'
Matcher = require 'parser/matchers/matcher'
Definition = require 'parser/matchers/definition'

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

it 'sets optional if all matchers in definition are optional', ->
    fn = (def)-> mk(def).optional

    expect(fn [req]).to.equal(false)
    expect(fn [opt]).to.equal(true)
    expect(fn [opt, req]).to.equal(false)
    expect(fn [req, opt]).to.equal(false)
    expect(fn [opt, opt]).to.equal(true)
    return

it 'generates symbols correctly', ->
    fn = (def)-> mk(def).symbols

    r = req.name
    o = opt.name
    b = grammar.between.name

    expect(fn [req]).deep.equal([r])
    expect(fn [req, req]).deep.equal([r, b, r])
    return
