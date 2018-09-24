{Node, Value} = require 'parser/ast'

exports.Function =
class Function extends Node
    init: (name, parameters, body)->
        @name = name.value
        @parameters = parameters.childNodes
        @body = body.childNodes[1]?.childNodes ? []

exports.Identifier =
class Identifier extends Node
    init: (regex)->
        [first, remaining] = regex.childNodes
        @value = first.data + (remaining.data ? "")

exports.Document =
class Document extends Node
    init: (_, body)->
        @statements = body.childNodes

exports.Assignment =
class Assignment extends Node
    init: (@destination, @source)->

exports.IntegerDecimal =
class IntegerDecimal extends Node
    init: (regex)->
        @value = regex.data

exports.StringSimple =
class StringSimple extends Node
    init: (regex)->
        @value = regex.data

exports.Call =
class Call extends Node
    init: (callable, args)->
        @callable = callable
        @arguments = args.childNodes

exports.While =
class While extends Node
    init: (condition, body)->
        @condition = condition
        @body = body.childNodes[1]?.childNodes ? []

exports.If =
class If extends Node
    init: (condition, body, else_)->
        @condition = condition
        @body = body.childNodes[1]?.childNodes ? []
        @else = else_.childNodes[1]?.childNodes ? []

exports.IfElif =
class IfElif extends Node
    init: (condition, body)->
        @condition = condition
        @body = body.childNodes[1]?.childNodes ? []
