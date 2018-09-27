{Node, Value} = require 'parser/ast'
        
elementsFromBlock = (node)->
    node.childNodes[1]?.childNodes ? []

exports.Function =
class Function extends Node
    init: (name, parameters, body)->
        @name = name
        @parameters = parameters.childNodes
        @body = elementsFromBlock body

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
        @body = elementsFromBlock body

exports.If =
class If extends Node
    init: (condition, body, else_)->
        @condition = condition
        @body = elementsFromBlock body
        @else = elementsFromBlock else_

exports.IfElif =
class IfElif extends Node
    init: (condition, body)->
        @condition = condition
        @body = elementsFromBlock body

exports.VariableDefinition =
class VariableDefinition extends Node
    init: (@name, @type)->

exports.FunctionParameter =
class FunctionParameter extends Node
    init: (@name, @type)->

exports.ClassDefinition =
class ClassDefinition extends Node
    init: (@name, body)->
        @body = elementsFromBlock body

exports.ClassField =
class ClassField extends Node
    init: (@name, @type)->

exports.TypeSimple =
class TypeSimple extends Node
    init: (@name)->

exports.TypeGeneric =
class TypeGeneric extends Node
    init: (@type, args)->
        @args = args.childNodes
