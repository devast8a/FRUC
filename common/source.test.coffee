{expect} = require 'chai'
Source = require './source'

describe 'offsetToColumn', ->
    test 'returns the text from given lines', ->
        source = Source.fromText [
            "a\n"
            "12\r\n"
            "xyz\r"
            "abcdef\n"
        ].join("")

        columns = [
            0, 1,
            0, 1, 2, 3
            0, 1, 2, 3
            0, 1, 2, 3, 4, 5, 6
        ]
        for column, offset in columns
            expect(source.offsetToColumn(offset)).equal(column)
        return

describe 'offsetToLine', ->
    test 'returns the text from given lines', ->
        source = Source.fromText [
            "a\n"
            "12\r\n"
            "xyz\r"
            "abcdef\n"
        ].join("")

        lines = [
            0, 0,
            1, 1, 1, 1
            2, 2, 2, 2
            3, 3, 3, 3, 3, 3, 3
        ]
        for line, offset in lines
            expect(source.offsetToLine(offset)).equal(line)
        return

describe 'lineToString', ->
    test 'returns the text of the given line', ->
        source = Source.fromText "a\n12\r\nxyz\rabcdef\n"
        expect(source.lineToString(0)).equal("a")
        expect(source.lineToString(1)).equal("12")
        expect(source.lineToString(2)).equal("xyz")
        return

    test 'returns last line with text', ->
        source = Source.fromText "123456"
        expect(source.lineToString(0)).equal("123456")

        source = Source.fromText "abcdef\n123456"
        expect(source.lineToString(1)).equal("123456")
        return

    test 'returns last line with nothing', ->
        source = Source.fromText ""
        expect(source.lineToString(0)).equal("")

        source = Source.fromText "abcdef\n"
        expect(source.lineToString(1)).equal("")
        return

describe 'linesToString', ->
    test 'returns the text from given lines', ->
        source = Source.fromText "a\n12\r\nxyz\rabcdef\n"
        expect(source.linesToString(1, 1)).equal("")
        expect(source.linesToString(0, 1)).equal("a")
        expect(source.linesToString(1, 2)).equal("12")
        expect(source.linesToString(0, 2)).equal("a\n12")
        expect(source.linesToString(1, 3)).equal("12\r\nxyz")
        return

describe 'linesToList', ->
    test 'returns the text from given lines', ->
        source = Source.fromText "a\n12\r\nxyz\rabcdef\n"
        expect(source.linesToList(0, 1)).deep.equal([[0, "a"]])
        expect(source.linesToList(1, 2)).deep.equal([[1, "12"]])
        expect(source.linesToList(0, 2)).deep.equal([[0, "a"], [1, "12"]])
        expect(source.linesToList(1, 3)).deep.equal([[1, "12"], [2, "xyz"]])
        return
