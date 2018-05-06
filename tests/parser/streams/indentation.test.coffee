{expect} = require 'chai'

Sink = require 'parser/streams/sink'
IndentationStream = require 'parser/streams/indentation'

run = (input...)->
    sink = new Sink
    stream = new IndentationStream sink
    for element in input
        stream.feed element
    stream.end()
    return sink.data

INDENT = IndentationStream.INDENT
DEDENT = IndentationStream.DEDENT

################################################################################

it 'passes through empty strings', ->
    expect(run '').deep.equal([''])
    expect(run 'a', '', 'b', '').deep.equal(['a', '', 'b', ''])
    return

it 'passes through text without altering it', ->
    expect(run 'helloworld').deep.equal(['helloworld'])
    expect(run 'hello', 'world').deep.equal(['hello', 'world'])
    return

it 'passes through a token without altering it', ->
    token = {token: 'test'}
    expect(run token).deep.equal([token])
    return

it 'injects indentation tokens', ->
    expect(run "hello\n    things").contains(INDENT, DEDENT)
    return

it 'calls feed for each line', ->
    expect(run 'a\nb\n').deep.equal(['a', '\n', 'b', '\n'])
    expect(run 'a\nb\nc').deep.equal(['a', '\n', 'b', '\n', 'c'])
    return

it 'injects INDENT after newline', ->
    expect(run 'a\n    b').deep.equal(
        ['a', '\n', INDENT, 'b', DEDENT]
    )
    return

it 'injects DEDENT before newline', ->
    expect(run 'a\n    b\nc').deep.equal(
        ['a', '\n', INDENT, 'b', DEDENT, '\n', 'c']
    )
    return

it 'handles multiple indentations correctly', ->
    expect(run 'a\n  b\nc\n  d\n').deep.equal(
        ['a', '\n', INDENT, 'b', DEDENT, '\n', 'c', '\n', INDENT, 'd', DEDENT, '\n']
    )
    return

it 'injects multiple DEDENT', ->
    expect(run 'a\n b\n  c\nd').deep.equal(
        ['a', '\n', INDENT, 'b', '\n', INDENT, 'c', DEDENT, DEDENT, '\n', 'd']
    )
    return

it 'injects multiple DEDENT automatically', ->
    expect(run 'a\n b\n  c').deep.equal(
        ['a', '\n', INDENT, 'b', '\n', INDENT, 'c', DEDENT, DEDENT]
    )
    return

it 'injects DEDENT after ending newline automatically', ->
    expect(run 'a\n b\n  c\n').deep.equal(
        ['a', '\n', INDENT, 'b', '\n', INDENT, 'c', DEDENT, DEDENT, '\n']
    )
    return

it 'handles all newline formats', ->
    expect(run 'a\r b\r\nc\n').deep.equal(
        ['a', '\r', INDENT, 'b', DEDENT, '\r\n', 'c', '\n']
    )
    return

it 'injects DEDENT and INDENTS on mixed indentation', ->
    expect(run 'a\n b\n  c\n\t\td').deep.equal(
        ['a', '\n', INDENT, 'b', '\n', INDENT, 'c', DEDENT, DEDENT, '\n', INDENT, 'd', DEDENT]
    )
    return
