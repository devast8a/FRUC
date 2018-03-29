Builder = require './matchers/builder'
Optional = require './matchers/optional'
Repeat = require './matchers/repeat'

exports.Opt =
Opt = (rule, options)-> new Builder Optional, options, rule

exports.Rep =
Rep = (rule, options)-> new Builder Repeat, options, rule

exports.OptRep =
OptRep = (rule, options)-> Opt Rep(rule), options
