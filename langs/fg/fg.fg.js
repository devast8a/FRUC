var Grammar = require("../../parser/grammar")
var {Rep, Opt, OptRep, Token, importSpace} = require("../../parser/grammar/helpers")
var grammar = new Grammar()
module.exports = grammar
var tags = require('./nodes');
var Node = require("../../parser/ast").Node
grammar.define(function(){
    function R(rule){
        return grammar.rule(rule)
    }
    function T(tag){
        if(tags[tag] === undefined){
            class AutomaticallyGeneratedNode extends Node {
                __process(definition, data, nodes){
                    this.__automatic(definition, data, nodes);
                }
            }
            Object.defineProperty(AutomaticallyGeneratedNode, "name", { value: tag });
            tags[tag] = AutomaticallyGeneratedNode;
        }
        return tags[tag];
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
        process: T('Document')
    })
    R('statements').add([Rep(R('statement'), {separator: R('NEWLINE')})], {
        process: T('statements'),
        automatic_process: true,
        definition_names: [null]
    })
    R('statement').add([R('rule')], {
        process: T('statement'),
        automatic_process: true,
        definition_names: ["rule"]
    })
    R('rule').add([Rep(R('reference'), {separator: grammar.SPACE}), '=', R('definition'), Opt(R('rule').rule('tag')), Opt(R('rule').rule('rule_body'))], {
        process: T('Rule')
    })
        // Subrules
        R('rule').rule('rule_body').add([R('INDENT'), R('statements'), R('DEDENT')], {
            process: T('rule_body'),
            automatic_process: true,
            definition_names: ["INDENT","statements","DEDENT"]
        })
        R('rule').rule('rule_body').add([R('processor')], {
            process: T('Processor')
        })
        R('rule').rule('tag').add(['::', R('reference')], {
            process: T('tag'),
            automatic_process: true,
            definition_names: [null,"reference"]
        })
    
    R('statement').add([R('option')], {
        process: T('statement'),
        automatic_process: true,
        definition_names: ["option"]
    })
    R('option').add([R('identifier'), ':', R('atom')], {
        process: T('Option')
    })
    R('statement').add([R('processor')], {
        process: T('Processor')
    })
    R('processor').add([Opt(R('processor').rule('parameters')), '->', grammar.NO_SPACE, R('processor').rule('processor_body')], {
        process: T('processor'),
        automatic_process: true,
        definition_names: [null,null,"NO_SPACE","processor_body"]
    })
        // Subrules
        R('processor').rule('parameters').add(['(', Rep(R('processor').rule('parameter'), {separator: ','}), ')'], {
            process: T('parameters'),
            automatic_process: true,
            definition_names: [null,null,null]
        })
        R('processor').rule('parameter').add([R('identifier')], {
            process: T('parameter'),
            automatic_process: true,
            definition_names: ["identifier"]
        })
        R('processor').rule('processor_body').add([/[^\n]+/], {
            process: T('processor_body'),
            automatic_process: true,
            definition_names: [null]
        })
        R('processor').rule('processor_body').add([R('INDENT'), Rep(R('processor').rule('processor_body').rule('line')), R('DEDENT')], {
            process: T('processor_body'),
            automatic_process: true,
            definition_names: ["INDENT",null,"DEDENT"]
        })
            // Subrules
            R('processor').rule('processor_body').rule('line').add([/[^\n]+\n/], {
                process: T('line'),
                automatic_process: true,
                definition_names: [null]
            })
    R('definition').add([Rep(R('matcher'), {separator: grammar.SPACE})], {
        process: T('Definition')
    })
    R('matcher').add([R('atom')], {
        process: T('matcher'),
        automatic_process: true,
        definition_names: ["atom"]
    })
    R('matcher').add([R('repetition')], {
        process: T('matcher'),
        automatic_process: true,
        definition_names: ["repetition"]
    })
    R('identifier').add([/[a-zA-Z_]+/], {
        process: T('Identifier')
    })
    R('reference').add([Opt(/[@]/), grammar.NO_SPACE, Rep(R('identifier'), {separator: '.'})], {
        process: T('Reference')
    })
        // Linked
        R('atom').add([R('reference')])
        
    
    R('atom').add([R('string')], {
        process: T('atom'),
        automatic_process: true,
        definition_names: ["string"]
    })
    R('string').add([/'[^\r\n']*'/], {
        process: T('String')
    })
    R('string').add([/"[^\r\n"]*"/], {
        process: T('String')
    })
    R('regex').add([/\/[^\n]+\//], {
        process: T('Regex')
    })
        // Linked
        R('atom').add([R('regex')])
        
    
    R('token').add(['%', grammar.NO_SPACE, R('identifier')], {
        process: T('Token')
    })
        // Linked
        R('atom').add([R('token')])
        
    
    R('repetition').add([R('atom'), '?'], {
        process: T('Opt')
    })
    R('repetition').add([R('atom'), '+'], {
        process: T('Rep')
    })
    R('repetition').add([R('atom'), '*'], {
        process: T('OptRep')
    })
    R('repetition').add([R('atom'), '++', R('atom')], {
        process: T('Rep')
    })
    R('repetition').add([R('atom'), '**', R('atom')], {
        process: T('OptRep')
    })
    grammar.between.add([Opt(grammar.SPACE)])
    R('WS').add([Rep(R('WS').rule('WS_'))], {
        ignore: grammar.true,
        process: T('WS'),
        automatic_process: true,
        definition_names: [null]
    })
        // Subrules
        R('WS').rule('WS_').add([/[ \t\n]/], {
            process: T('WS_'),
            automatic_process: true,
            definition_names: [null]
        })
        R('WS').rule('WS_').add([/#[^\n]*\n/], {
            process: T('WS_'),
            automatic_process: true,
            definition_names: [null]
        })
    
    R('NEWLINE').add([Opt(R('NEWLINE').rule('NEWLINE_')), '\n', Opt(R('WS'))], {
        ignore: grammar.true,
        process: T('NEWLINE'),
        automatic_process: true,
        definition_names: [null,null,null]
    })
        // Subrules
        R('NEWLINE').rule('NEWLINE_').add([/[ \t]+/], {
            process: T('NEWLINE_'),
            automatic_process: true,
            definition_names: [null]
        })
        R('NEWLINE').rule('NEWLINE_').add([/[ \t]*#[^\n]*/], {
            process: T('NEWLINE_'),
            automatic_process: true,
            definition_names: [null]
        })
    
    R('INDENT').add([Opt(R('WS')), Token("INDENT")], {
        ignore: grammar.true,
        process: T('INDENT'),
        automatic_process: true,
        definition_names: [null,null]
    })
    R('DEDENT').add([Opt(R('WS')), Token("DEDENT")], {
        ignore: grammar.true,
        process: T('DEDENT'),
        automatic_process: true,
        definition_names: [null,null]
    })

    if(grammar.between.definitions.length == 0){
        grammar.between.add('')
    }
});
if(tags.onGrammarDefined !== undefined){
    tags.onGrammarDefined(grammar)
}