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

    grammar.name='FRUC Grammar Language'
    grammar.author='devast8a'
    grammar.root.add([Opt(R('WS')), R('statements'), Opt(R('WS'))], {
        process: tags.Document
    })
    R('statements').add([Rep(R('statement'), {separator: R('NEWLINE')})])
    R('statement').add([R('rule')])
    R('rule').add([Rep(R('reference'), {separator: grammar.SPACE}), '=', R('definition'), Opt(R('rule').rule('tag')), Opt(R('rule').rule('rule_body'))], {
        process: tags.Rule
    })
        // Subrules
        R('rule').rule('rule_body').add([R('INDENT'), R('statements'), R('DEDENT')])
        R('rule').rule('rule_body').add([R('processor')], {
            process: tags.Processor
        })
        R('rule').rule('tag').add(['::', R('reference')])
    
    R('statement').add([R('option')])
    R('option').add([R('identifier'), ':', R('atom')], {
        process: tags.Option
    })
    R('statement').add([R('processor')], {
        process: tags.Processor
    })
    R('processor').add([Opt(R('processor').rule('parameters')), '->', grammar.NO_SPACE, R('processor').rule('processor_body')])
        // Subrules
        R('processor').rule('parameters').add(['(', Rep(R('processor').rule('parameter'), {separator: ','}), ')'])
        R('processor').rule('parameter').add([R('identifier')])
        R('processor').rule('processor_body').add([/[^\n]+/])
        R('processor').rule('processor_body').add([R('INDENT'), Rep(R('processor').rule('processor_body').rule('line')), R('DEDENT')])
            // Subrules
            R('processor').rule('processor_body').rule('line').add([/[^\n]+\n/])
    R('definition').add([Rep(R('matcher'), {separator: grammar.SPACE})], {
        process: tags.Definition
    })
    R('matcher').add([R('atom')])
    R('matcher').add([R('repetition')])
    R('identifier').add([/[a-zA-Z_]+/], {
        process: tags.Identifier
    })
    R('reference').add([Opt(/[@]/), grammar.NO_SPACE, Rep(R('identifier'), {separator: '.'})], {
        process: tags.Reference
    })
        // Linked
        R('atom').add([R('reference')])
        
    
    R('atom').add([R('string')])
    R('string').add([/'[^\r\n']*'/], {
        process: tags.String
    })
    R('string').add([/"[^\r\n"]*"/], {
        process: tags.String
    })
    R('regex').add([/\/[^\n]+\//], {
        process: tags.Regex
    })
        // Linked
        R('atom').add([R('regex')])
        
    
    R('token').add(['%', grammar.NO_SPACE, R('identifier')], {
        process: tags.Token
    })
        // Linked
        R('atom').add([R('token')])
        
    
    R('repetition').add([R('atom'), '?'], {
        process: tags.Opt
    })
    R('repetition').add([R('atom'), '+'], {
        process: tags.Rep
    })
    R('repetition').add([R('atom'), '*'], {
        process: tags.OptRep
    })
    R('repetition').add([R('atom'), '++', R('atom')], {
        process: tags.Rep
    })
    R('repetition').add([R('atom'), '**', R('atom')], {
        process: tags.OptRep
    })
    grammar.between.add([Opt(grammar.SPACE)])
    R('WS').add([Rep(R('WS').rule('WS_'))], {
        ignore: grammar.true
    })
        // Subrules
        R('WS').rule('WS_').add([/[ \t\n]/])
        R('WS').rule('WS_').add([/#[^\n]*\n/])
    
    R('NEWLINE').add([Opt(R('NEWLINE').rule('NEWLINE_')), '\n', Opt(R('WS'))], {
        ignore: grammar.true
    })
        // Subrules
        R('NEWLINE').rule('NEWLINE_').add([/[ \t]+/])
        R('NEWLINE').rule('NEWLINE_').add([/[ \t]*#[^\n]*/])
    
    R('INDENT').add([Opt(R('WS')), Token("INDENT")], {
        ignore: grammar.true
    })
    R('DEDENT').add([Opt(R('WS')), Token("DEDENT")], {
        ignore: grammar.true
    })

    if(grammar.between.definitions.length == 0){
        grammar.between.add('')
    }
});
if(tags.onGrammarDefined !== undefined){
    tags.onGrammarDefined(grammar)
}