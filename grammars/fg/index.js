try{
    module.exports = require("./fg.fg.js")
}
catch(err){
    console.log("Using fg backup")
    module.exports = require("./backup.js")
}
