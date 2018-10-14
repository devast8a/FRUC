# Take FirRegFunction and convert to C

FirReg = require '../../compiler/fir/reg-r/instructions'
{Kind} = require '../../compiler/fir/reg-r/function'
{Text} = require '../text'

converters = new Array FirReg.OpCodes.length

mangleName = (name)->
    name = name.replace '$', '_DOLLAR_'
    return name

handleValue = (value)->
    switch value.kind
        when Kind.LOCAL
            return mangleName value.name

        when Kind.CONSTANT
            # TODO: Double check constants are supported correctly
            return JSON.stringify value.value

        else
            throw new Error "Unknown kind #{value.kind}"

converters[FirReg.Call::opcode] = (instruction, content)->
    content.push "    "
    if instruction.dst?
        content.push handleValue instruction.dst
        content.push " = "
    else
        content.push "(void) "

    content.push mangleName instruction.function
    content.push "("
    content.push instruction.args.map(handleValue).join(", ")
    content.push ");\n"

converters[FirReg.Assign::opcode] = (instruction, content)->
    content.push "    "
    content.push handleValue instruction.dst
    content.push " = "
    content.push handleValue instruction.src
    content.push ";\n"

converters[FirReg.Jump::opcode] = (instruction, content)->
    content.push "    goto "
    content.push instruction.target.name
    content.push ";\n"

converters[FirReg.BranchTrue::opcode] = (instruction, content)->
    content.push "    if("
    content.push handleValue instruction.value
    content.push "){ goto "
    content.push instruction.target.name
    content.push "; }\n"

converters[FirReg.BranchFalse::opcode] = (instruction, content)->
    content.push "    if(!("
    content.push handleValue instruction.value
    content.push ")){ goto "
    content.push instruction.target.name
    content.push "; }\n"

converters[FirReg.Return::opcode] = (instruction, content)->
    content.push "    return"
    if instruction.src?
        content.push " "
        content.push handleValue instruction.src
    content.push ";\n"

exports.output =
output = (type)->
    content = []

    content.push '#include "fruclib.h"\n'

    for fn in type.registerResolvedFunctions
        content.push 'int '
        content.push mangleName fn.name
        content.push '('

        for parameter in fn.locals
            if parameter.isParameter
                content.push parameter.type
                content.push " "
                content.push mangleName parameter.name

        content.push ') {\n'

        # Define locals
        for local in fn.locals
            content.push "    "
            content.push local.type
            content.push " "
            content.push mangleName local.name
            content.push ";\n"

        instructionToLabels = new Array fn.instructions.length + 1
        for label in fn.labels
            (instructionToLabels[label.target] ?= []).push label

        # Convert instructions
        for instruction in fn.instructions
            handler = converters[instruction.opcode]

            if (labels = instructionToLabels[instruction.offset])?
                for label in labels
                    content.push label.name
                    content.push ": "
                content.push "\n"

            if handler?
                handler instruction, content
            else
                throw new Error "#{instruction.constructor.name} does not have a handler"

        content.push '}\n'

    return content.join ""
