Grammar = require 'parsing/grammar'
Parser = require 'parsing/parser'

describe 'Grammar::between', ->
    it 'is inserted between sequences of symbols', ->
        grammar = new Grammar
        grammar.define ->
            grammar.root.add @rule
            grammar.between.add ' '

            @rule.add ['x']
            @rule.add ['x', 'y']
            @rule.add ['x', 'y', 'z']

        parser = new Parser grammar
        
        parser.parse 'x'
        parser.parse 'x y'
        parser.parse 'x y z'
        return

    it 'is optional when empty', ->
        grammar = new Grammar
        grammar.define ->
            grammar.root.add @rule

            @rule.add ['x']
            @rule.add ['x', 'y']
            @rule.add ['x', 'y', 'z']

        parser = new Parser grammar

        parser.parse 'x'
        parser.parse 'xy'
        parser.parse 'xyz'
        return

    it 'is required when non-empty', ->
        grammar = new Grammar
        grammar.define ->
            grammar.root.add @rule
            grammar.between.add ' '

            @rule.add ['x']
            @rule.add ['x', 'y']
            @rule.add ['x', 'y', 'z']

        parser = new Parser grammar

        parser.parse 'x y z'
        expect(-> parser.parse 'xy').toThrow()
        expect(-> parser.parse 'xyz').toThrow()
        return
