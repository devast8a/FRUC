coffee = require 'coffeescript'

exports.process = (src, path)->
    if coffee.helpers.isCoffee path
        return coffee.compile src,
            bare: true
            inlineMap: true
            filename: path
    return src
