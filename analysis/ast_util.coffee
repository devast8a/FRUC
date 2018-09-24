exports.visit =
visit = (visitors, node, options)->
    fn = visitors.get node.constructor
    
    if fn != undefined
        fn node, options

    for child in node.childNodes
        visit visitors, child, options

exports.displayAst =
displayAst = (value, indent = "", showName = true)->
    indentString = "    "

    if showName
        console.log("<" + value.constructor.name + ">")

    for key in Object.getOwnPropertyNames(value)
        continue if key == 'childNodes'
        continue if key == 'metadata'
        continue if key == 'map'

        member = value[key]

        if typeof(member) != 'object'
            console.log(indent + indentString + key + ": " + JSON.stringify(member))
        else
            console.log(indent + indentString + key + ": <" + member.constructor.name + ">")
            displayAst(member, indent + indentString, false)

