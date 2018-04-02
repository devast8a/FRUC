Builder = require './builder'
OptionalMatcher = require '../matchers/optional'
RepeatMatcher = require '../matchers/repeat'
TokenMatcher = require '../matchers/token'

exports.Opt =
Opt = (rule, options)-> new Builder OptionalMatcher, options, rule

exports.Rep =
Rep = (rule, options)-> new Builder RepeatMatcher, options, rule

exports.OptRep =
OptRep = (rule, options)-> Opt Rep(rule), options

exports.Token =
Token = (token, options)-> new Builder TokenMatcher, options, token

exports.importSpace =
importSpace = (grammar)->
    # Helpers used by the grammar
    SPACE = grammar.rule ':SPACE'
    SPACE.add /[ \t]+/
    SPACE.noBetween = true
    SPACE.ignoreOutput = true

    NO_SPACE = grammar.rule ':NOSPACE'
    NO_SPACE.add ''
    NO_SPACE.noBetween = true
    NO_SPACE.ignoreOutput = true

    SPACE_NL = grammar.rule ':SPACE_NL'
    SPACE_NL.add /[ \t\n\r]+/
    SPACE_NL.noBetween = true
    SPACE_NL.ignoreOutput = true

    return {
        SPACE: SPACE
        NO_SPACE: NO_SPACE
        SPACE_NL: SPACE_NL
    }
