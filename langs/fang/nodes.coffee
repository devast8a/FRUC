{Constant, LoadLocal, StoreLocal, BranchFalse, BranchTrue, Call, Jump} = require '../../compiler/fir/stack/instructions'
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

    defineStackSemantics: (fn, options)->
        # We are assuming execution as an expression
        # ie. We push the value of local onto stack
        md = options.metadata.get @value
        fn.addInstruction this, LoadLocal, md.local

exports.Document =
class Document extends Node
    init: (_, body)->
        @statements = body.childNodes

    defineStackSemantics: (fn, options)->
        for statement in @statements
            fn.addNode this, statement, options

exports.Assignment =
class Assignment extends Node
    init: (@destination, @source)->

    defineStackSemantics: (fn, options)->
        # TODO: Setup defineStackSemantics to signal to other nodes that we want to store a value.
        md = options.metadata.get @destination.value

        fn.addNode this, @source, options

        fn.addInstruction this, StoreLocal, md.local

exports.IntegerDecimal =
class IntegerDecimal extends Node
    init: (regex)->
        @value = regex.data

    defineStackSemantics: (fn, options)->
        fn.addInstruction this, Constant, "Int", @value

exports.StringSimple =
class StringSimple extends Node
    init: (regex)->
        @value = regex.data

    defineStackSemantics: (fn, options)->
        fn.addInstruction this, Constant, "String", @value

exports.CallNode =
class CallNode extends Node
    init: (call)->
        [callable, args] = call.childNodes
        @callable = callable
        @arguments = args.childNodes

    defineStackSemantics: (fn, options)->
        for argument in @arguments
            fn.addNode this, argument, options

        fn.addInstruction this, Call, @callable.value, @returns, @arguments.length

exports.CallStatement =
class CallStatement extends CallNode
    returns: false

exports.CallExpression =
class CallExpression extends CallNode
    returns: true

exports.While =
class While extends Node
    init: (condition, body)->
        @condition = condition
        @body = elementsFromBlock body

    defineStackSemantics: (fn, options)->
        condition = fn.addLabel 'condition'
        body = fn.addLabel 'body'

        fn.addInstruction this, Jump, condition
        fn.mark this, body
        for node in @body
            fn.addNode this, node, options
        fn.mark this, condition
        fn.addNode this, @condition, options
        fn.addInstruction this, BranchTrue, body

exports.If =
class If extends Node
    init: (condition, body, _, else_)->
        @condition = condition
        @body = elementsFromBlock body
        @else = elementsFromBlock else_

    defineStackSemantics: (fn, options)->
        end = fn.addLabel 'end'
        falseBranch = fn.addLabel 'falseBranch'

        fn.addNode this, @condition, options
        fn.addInstruction this, BranchFalse, falseBranch

        # True Branch
        for node in @body
            fn.addNode this, node, options
        fn.addInstruction this, Jump, end

        fn.mark this, falseBranch
        for node in @else
            fn.addNode this, node, options
        
        fn.mark this, end

exports.IfElif =
class IfElif extends Node
    init: (condition, body)->
        @condition = condition
        @body = elementsFromBlock body

exports.VariableDefinition =
class VariableDefinition extends Node
    init: (@name, @type)->

    defineStackSemantics: (fn, options)->
        md = options.metadata.get @name.value
        md.local = fn.addLocal @type.name.value, @name.value

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
