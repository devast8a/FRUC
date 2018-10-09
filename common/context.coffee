exports.Context =
class Context
    constructor: ->
        @errors = []

    error: (error)->
        @errors.push error
