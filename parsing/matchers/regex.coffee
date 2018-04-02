# Regular expression parser
{parse} = require 'regulex'

Any = require './any'
Charset = require './charset'
Constant = require './constant'
{Rep, Opt} = require '../grammar/helpers'

module.exports =
class Regex extends Any
    toString: -> @regex.toString()

    init: (@regex)->
        super()
        @options.between = null
        ast = parse @regex.source
        @add @build_seq ast.tree

    build_seq: (seq)->
        (@build node for node in seq)

    build: (node)->
        switch node.type
            when 'exact'
                matcher = @createMatcher Constant, null, node.chars

            when 'group'
                matcher = @createMatcher Any
                matcher.add @build_seq node.sub

            when 'choice'
                matcher = @createMatcher Any
                for branch in node.branches
                    matcher.add @build_seq branch

            when 'charset'
                raw = node.raw
                raw = raw.substr 0, raw.lastIndexOf(']') + 1
                regex = new RegExp raw

                matcher = @createMatcher Charset, null, regex

            else
                throw new Error "Unable to build matcher expression for regular expression. Unable to handle AST node type #{node.type}"

        # Build the matcher
        if node.repeat
            {min, max} = node.repeat

            matcher = Rep matcher

            if min == 0
                matcher = Opt matcher

        return matcher
