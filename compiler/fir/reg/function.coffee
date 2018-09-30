class Label
    constructor: (@name)->

class Local
    constructor: (@type, @name)->

exports.FirFunction =
class FirFunction
    constructor: ->
        @high = []
        @low = []
        @locals = []

    addLocal: (type, name)->
        local = new Local type, name
        @locals.push local
        return local

    addHigh: (instruction)->
        @high.push instruction

    addLabel: (name)->
        new Label name

    addLow: (parent, instruction)->
        if instruction instanceof Array
            for i in instruction
                @addLow parent, i
        else
            instruction.id = @low.length
            @low.push [parent, instruction]

    generateLowSemantics: ->
        for instruction in @high
            instruction.generateSemantics this

