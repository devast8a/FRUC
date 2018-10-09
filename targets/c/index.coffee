# Take FirRegFunction and convert to C

FirReg = require '../../compiler/fir/reg/instructions'

converters = new Array FirReg.OpCodes.length

mangleName = (name)->
    name = name.replace '$', '_DOLLAR_'
    return name

converters[FirReg.Call::opcode] = (instruction, content)->
    content.push "    "
    if instruction.dst?
        content.push mangleName instruction.dst.name
        content.push " = "
    else
        content.push "(void) "

    content.push mangleName instruction.function
    content.push "("
    content.push instruction.args.map((local)-> mangleName(local.name)).join(", ")
    content.push ");\n"

converters[FirReg.Assign::opcode] = (instruction, content)->
    content.push "    "
    content.push mangleName instruction.dst.name
    content.push " = "
    content.push mangleName instruction.src.name
    content.push ";\n"

converters[FirReg.Jump::opcode] = (instruction, content)->
    content.push "    goto "
    content.push instruction.target.name
    content.push ";\n"

converters[FirReg.BranchTrue::opcode] = (instruction, content)->
    content.push "    if("
    content.push mangleName instruction.value.name
    content.push "){ goto "
    content.push instruction.target.name
    content.push "; }\n"

converters[FirReg.BranchFalse::opcode] = (instruction, content)->
    content.push "    if(!("
    content.push mangleName instruction.value.name
    content.push ")){ goto "
    content.push instruction.target.name
    content.push "; }\n"

converters[FirReg.Return::opcode] = (instruction, content)->
    content.push "    return"
    if instruction.src?
        content.push " "
        content.push mangleName instruction.src.name
    content.push ";\n"

exports.output =
output = (fn)->
    content = []

    content.push '#include "fruclib.h"\n'
    content.push 'int main() {\n'

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

    content.push '}'

    return content.join ""
