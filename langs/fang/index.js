var Grammar = require("../../parser/grammar")
var {Rep, Opt, OptRep, Token, importSpace} = require("../../parser/grammar/helpers")
var grammar = new Grammar()
module.exports = grammar
var tags = require('./nodes')
grammar.define(function(){
    function R(rule){
        return grammar.rule(rule)
    }
    var {SPACE, NO_SPACE, SPACE_NL, NEWLINE} = importSpace(grammar)
    grammar.SPACE = SPACE
    grammar.NO_SPACE = NO_SPACE
    grammar.SPACE_NL = SPACE_NL
    grammar.NEWLINE = NEWLINE

    grammar.tags = tags
    grammar.null = null
    grammar.true = true
    grammar.false = false

    grammar.name='FANG'
    grammar.author='devast8a'
    R('document').add([Opt(R('WS')), Rep(R('statement')), Opt(R('WS'))], {
        process: tags.Document
    })
    R('block').add([R('block').rule('start'), Rep(R('statement')), R('block').rule('end')])
        // Subrules
        R('block').rule('start').add([R('INDENT')])
        R('block').rule('end').add([R('DEDENT')])
    
    R('function_definition').add(['def', R('function_definition').rule('name'), Opt(R('function_definition').rule('parameters')), '->', Opt(R('function_definition').rule('body'))], {
        process: tags.Function
    })
        // Linked
        R('statement').add([R('function_definition')])
        
        // Subrules
        R('function_definition').rule('body').add([R('block')])
        R('function_definition').rule('name').add([R('identifier')])
        R('function_definition').rule('parameters').add(['(', OptRep(R('function_definition').rule('parameter'), {separator: ','}), ')'])
        R('function_definition').rule('parameter').add([R('function_definition').rule('parameter').rule('name'), ':', R('function_definition').rule('parameter').rule('type')], {
            process: tags.FunctionParameter
        })
            // Subrules
            R('function_definition').rule('parameter').rule('name').add([R('identifier')])
            R('function_definition').rule('parameter').rule('type').add([R('identifier')])
    R('assignment').add([R('assignment').rule('assignable'), '=', R('expression')], {
        process: tags.Assignment
    })
        // Linked
        R('statement').add([R('assignment')])
        
        // Subrules
        R('assignment').rule('assignable').add([R('identifier')])
    
    R('function_call').add([R('function_call').rule('callable'), R('function_call').rule('arguments')], {
        process: tags.Call
    })
        // Linked
        R('statement').add([R('function_call')])
        R('expression').add([R('function_call')])
        
        // Subrules
        R('function_call').rule('callable').add([R('identifier')])
        R('function_call').rule('arguments').add(['(', OptRep(R('function_call').rule('argument'), {separator: ','}), ')'])
        R('function_call').rule('argument').add([R('expression')])
    
    R('statement').add([R('variable_definition')])
    R('variable_definition').add(['var', R('variable_definition').rule('name'), ':', R('variable_definition').rule('type')], {
        process: tags.VariableDefinition
    })
        // Subrules
        R('variable_definition').rule('name').add([R('identifier')])
        R('variable_definition').rule('type').add([R('identifier')])
    
    R('while').add(['while', R('while').rule('condition'), Opt(R('while').rule('body'))], {
        process: tags.While
    })
        // Linked
        R('statement').add([R('while')])
        
        // Subrules
        R('while').rule('condition').add([R('expression')])
        R('while').rule('body').add([R('block')])
    
    R('if').add(['if', R('if').rule('condition'), Opt(R('if').rule('body')), OptRep(R('if_elif')), Opt(R('if_else'))], {
        process: tags.If
    })
        // Linked
        R('statement').add([R('if')])
        
        // Subrules
        R('if').rule('condition').add([R('expression')])
        R('if').rule('body').add([R('block')])
    
    R('if_elif').add([R('if_elif').rule('keyword'), R('if_elif').rule('condition'), Opt(R('if_elif').rule('body'))], {
        process: tags.IfElif
    })
        // Subrules
        R('if_elif').rule('condition').add([R('expression')])
        R('if_elif').rule('keyword').add(['elif'])
        R('if_elif').rule('body').add([R('block')])
    
    R('if_else').add(['else', Opt(R('if_else').rule('body'))])
        // Subrules
        R('if_else').rule('body').add([R('block')])
    
    R('integer').add([/[0-9]+/], {
        process: tags.IntegerDecimal
    })
        // Linked
        R('expression').add([R('integer')])
        
    
    R('string').add([R('string').rule('string_')])
        // Linked
        R('expression').add([R('string')])
        
        // Subrules
        R('string').rule('single_quote').add([/'[^'\r\n]+'/], {
            process: tags.StringSimple
        })
            // Linked
            R('string').rule('string_').add([R('string').rule('single_quote')])
            
        
        R('string').rule('double_quote').add([/"[^"\r\n]+"/], {
            process: tags.StringSimple
        })
            // Linked
            R('string').rule('string_').add([R('string').rule('double_quote')])
            
    R('identifier').add([/[a-zA-Z_][a-zA-Z_0-9]*/], {
        process: tags.Identifier
    })
        // Linked
        R('expression').add([R('identifier')])
        
    
    grammar.root.add([R('document')])
    grammar.between.add([Opt(R('WS'))])
    R('WS').add([/[ \t\n]+/], {
        ignore: grammar.true
    })
    R('INDENT').add([Token("INDENT")], {
        ignore: grammar.true
    })
    R('DEDENT').add([Token("DEDENT")], {
        ignore: grammar.true
    })

    if(grammar.between.definitions.length == 0){
        grammar.between.add('')
    }
});
if(tags.onGrammarDefined !== undefined){
    tags.onGrammarDefined(grammar)
}