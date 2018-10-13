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
        process: T('Document'),
        start: {"offset":90,"line":5,"column":8},
        end: {"offset":108,"line":5,"column":26}
    })
    R('statements').add([Rep(R('statement'), {separator: R('NEWLINE')})], {
        process: T('statements'),
        automatic_process: true,
        definition_names: [null],
        start: {"offset":309,"line":10,"column":13},
        end: {"offset":327,"line":10,"column":31}
    })
    R('statement').add([R('rule')], {
        process: T('statement'),
        automatic_process: true,
        definition_names: ["rule"],
        start: {"offset":349,"line":13,"column":12},
        end: {"offset":353,"line":13,"column":16}
    })
    R('rule').add([Rep(R('reference'), {separator: grammar.SPACE}), '=', R('definition'), Opt(R('rule').rule('tag')), Opt(R('rule').rule('rule_body'))], {
        process: T('Rule'),
        start: {"offset":361,"line":14,"column":7},
        end: {"offset":409,"line":14,"column":55}
    })
        // Subrules
        R('rule').rule('rule_body').add([R('INDENT'), R('statements'), R('DEDENT')], {
            process: T('rule_body'),
            automatic_process: true,
            definition_names: ["INDENT","statements","DEDENT"],
            start: {"offset":431,"line":15,"column":13},
            end: {"offset":455,"line":15,"column":37}
        })
        R('rule').rule('rule_body').add([R('processor')], {
            process: T('Processor'),
            start: {"offset":468,"line":16,"column":9},
            end: {"offset":477,"line":16,"column":18}
        })
        R('rule').rule('tag').add(['::', R('reference')], {
            process: T('tag'),
            automatic_process: true,
            definition_names: [null,"reference"],
            start: {"offset":497,"line":16,"column":38},
            end: {"offset":511,"line":17,"column":13}
        })
    
    R('statement').add([R('option')], {
        process: T('statement'),
        automatic_process: true,
        definition_names: ["option"],
        start: {"offset":536,"line":20,"column":2},
        end: {"offset":542,"line":20,"column":8}
    })
    R('option').add([R('identifier'), ':', R('atom')], {
        process: T('Option'),
        start: {"offset":552,"line":20,"column":18},
        end: {"offset":571,"line":21,"column":18}
    })
    R('statement').add([R('processor')], {
        process: T('Processor'),
        start: {"offset":607,"line":24,"column":2},
        end: {"offset":616,"line":24,"column":11}
    })
    R('processor').add([Opt(R('processor').rule('parameters')), '->', grammar.NO_SPACE, R('processor').rule('processor_body')], {
        process: T('processor'),
        automatic_process: true,
        definition_names: [null,null,"NO_SPACE","processor_body"],
        start: {"offset":642,"line":25,"column":2},
        end: {"offset":683,"line":25,"column":43}
    })
        // Subrules
        R('processor').rule('parameters').add(['(', Rep(R('processor').rule('parameter'), {separator: ','}), ')'], {
            process: T('parameters'),
            automatic_process: true,
            definition_names: [null,null,null],
            start: {"offset":698,"line":26,"column":4},
            end: {"offset":720,"line":26,"column":26}
        })
        R('processor').rule('parameter').add([R('identifier')], {
            process: T('parameter'),
            automatic_process: true,
            definition_names: ["identifier"],
            start: {"offset":733,"line":26,"column":39},
            end: {"offset":743,"line":27,"column":9}
        })
        R('processor').rule('processor_body').add([/[^\n]+/], {
            process: T('processor_body'),
            automatic_process: true,
            definition_names: [null],
            start: {"offset":761,"line":28,"column":0},
            end: {"offset":769,"line":28,"column":8}
        })
        R('processor').rule('processor_body').add([R('INDENT'), Rep(R('processor').rule('processor_body').rule('line')), R('DEDENT')], {
            process: T('processor_body'),
            automatic_process: true,
            definition_names: ["INDENT",null,"DEDENT"],
            start: {"offset":787,"line":28,"column":26},
            end: {"offset":806,"line":29,"column":15}
        })
            // Subrules
            R('processor').rule('processor_body').rule('line').add([/[^\n]+\n/], {
                process: T('line'),
                automatic_process: true,
                definition_names: [null],
                start: {"offset":815,"line":29,"column":24},
                end: {"offset":825,"line":29,"column":34}
            })
    R('definition').add([Rep(R('matcher'), {separator: grammar.SPACE})], {
        process: T('Definition'),
        start: {"offset":1018,"line":34,"column":64},
        end: {"offset":1033,"line":34,"column":79}
    })
    R('matcher').add([R('atom')], {
        process: T('matcher'),
        automatic_process: true,
        definition_names: ["atom"],
        start: {"offset":1059,"line":35,"column":24},
        end: {"offset":1063,"line":35,"column":28}
    })
    R('matcher').add([R('repetition')], {
        process: T('matcher'),
        automatic_process: true,
        definition_names: ["repetition"],
        start: {"offset":1074,"line":35,"column":39},
        end: {"offset":1084,"line":37,"column":5}
    })
    R('identifier').add([/[a-zA-Z_]+/], {
        process: T('Identifier'),
        start: {"offset":1112,"line":38,"column":18},
        end: {"offset":1124,"line":40,"column":8}
    })
    R('reference').add([Opt(/[@]/), grammar.NO_SPACE, Rep(R('identifier'), {separator: '.'})], {
        process: T('Reference'),
        start: {"offset":1169,"line":42,"column":0},
        end: {"offset":1201,"line":44,"column":19}
    })
        // Linked
        R('atom').add([R('reference')],{start: {"offset":1169,"line":42,"column":0},end: {"offset":1201,"line":44,"column":19}})
        
    
    R('atom').add([R('string')], {
        process: T('atom'),
        automatic_process: true,
        definition_names: ["string"],
        start: {"offset":1294,"line":47,"column":38},
        end: {"offset":1300,"line":47,"column":44}
    })
    R('string').add([/'[^\r\n']*'/], {
        process: T('String'),
        start: {"offset":1310,"line":47,"column":54},
        end: {"offset":1323,"line":48,"column":6}
    })
    R('string').add([/"[^\r\n"]*"/], {
        process: T('String'),
        start: {"offset":1343,"line":49,"column":12},
        end: {"offset":1356,"line":49,"column":25}
    })
    R('regex').add([/\/[^\n]+\//], {
        process: T('Regex'),
        start: {"offset":1389,"line":50,"column":25},
        end: {"offset":1401,"line":52,"column":3}
    })
        // Linked
        R('atom').add([R('regex')],{start: {"offset":1389,"line":50,"column":25},end: {"offset":1401,"line":52,"column":3}})
        
    
    R('token').add(['%', grammar.NO_SPACE, R('identifier')], {
        process: T('Token'),
        start: {"offset":1434,"line":53,"column":28},
        end: {"offset":1458,"line":56,"column":7}
    })
        // Linked
        R('atom').add([R('token')],{start: {"offset":1434,"line":53,"column":28},end: {"offset":1458,"line":56,"column":7}})
        
    
    R('repetition').add([R('atom'), '?'], {
        process: T('Opt'),
        start: {"offset":1495,"line":56,"column":44},
        end: {"offset":1503,"line":58,"column":4}
    })
    R('repetition').add([R('atom'), '+'], {
        process: T('Rep'),
        start: {"offset":1530,"line":59,"column":18},
        end: {"offset":1538,"line":59,"column":26}
    })
    R('repetition').add([R('atom'), '*'], {
        process: T('OptRep'),
        start: {"offset":1565,"line":60,"column":18},
        end: {"offset":1573,"line":60,"column":26}
    })
    R('repetition').add([R('atom'), '++', R('atom')], {
        process: T('Rep'),
        start: {"offset":1603,"line":61,"column":21},
        end: {"offset":1617,"line":61,"column":35}
    })
    R('repetition').add([R('atom'), '**', R('atom')], {
        process: T('OptRep'),
        start: {"offset":1638,"line":62,"column":18},
        end: {"offset":1652,"line":62,"column":32}
    })
    grammar.between.add([Opt(grammar.SPACE)], {
        start: {"offset":1850,"line":67,"column":62},
        end: {"offset":1857,"line":67,"column":69}
    })
    R('WS').add([Rep(R('WS').rule('WS_'))], {
        ignore: grammar.true,
        process: T('WS'),
        automatic_process: true,
        definition_names: [null],
        start: {"offset":1864,"line":67,"column":76},
        end: {"offset":1868,"line":67,"column":80}
    })
        // Subrules
        R('WS').rule('WS_').add([/[ \t\n]/], {
            process: T('WS_'),
            automatic_process: true,
            definition_names: [null],
            start: {"offset":1876,"line":68,"column":7},
            end: {"offset":1885,"line":68,"column":16}
        })
        R('WS').rule('WS_').add([/#[^\n]*\n/], {
            process: T('WS_'),
            automatic_process: true,
            definition_names: [null],
            start: {"offset":1892,"line":70,"column":3},
            end: {"offset":1903,"line":71,"column":4}
        })
    
    R('NEWLINE').add([Opt(R('NEWLINE').rule('NEWLINE_')), '\n', Opt(R('WS'))], {
        ignore: grammar.true,
        process: T('NEWLINE'),
        automatic_process: true,
        definition_names: [null,null,null],
        start: {"offset":1930,"line":72,"column":11},
        end: {"offset":1948,"line":73,"column":7}
    })
        // Subrules
        R('NEWLINE').rule('NEWLINE_').add([/[ \t]+/], {
            process: T('NEWLINE_'),
            automatic_process: true,
            definition_names: [null],
            start: {"offset":1961,"line":75,"column":1},
            end: {"offset":1969,"line":75,"column":9}
        })
        R('NEWLINE').rule('NEWLINE_').add([/[ \t]*#[^\n]*/], {
            process: T('NEWLINE_'),
            automatic_process: true,
            definition_names: [null],
            start: {"offset":1981,"line":75,"column":21},
            end: {"offset":1996,"line":76,"column":7}
        })
    
    R('INDENT').add([Opt(R('WS')), Token("INDENT")], {
        ignore: grammar.true,
        process: T('INDENT'),
        automatic_process: true,
        definition_names: [null,null],
        start: {"offset":2022,"line":77,"column":9},
        end: {"offset":2033,"line":77,"column":20}
    })
    R('DEDENT').add([Opt(R('WS')), Token("DEDENT")], {
        ignore: grammar.true,
        process: T('DEDENT'),
        automatic_process: true,
        definition_names: [null,null],
        start: {"offset":2060,"line":78,"column":16},
        end: {"offset":2071,"line":80,"column":8}
    })

    if(grammar.between.definitions.length == 0){
        grammar.between.add('')
    }
});
if(tags.onGrammarDefined !== undefined){
    tags.onGrammarDefined(grammar)
}