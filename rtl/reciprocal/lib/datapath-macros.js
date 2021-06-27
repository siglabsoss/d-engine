'use strict';

const reqack = require('reqack');
const _ = require('lodash');
const range = _.range;
const lzc = require('./lzc.js');

const forkCtrl = reqack.ctrl.fork;
const deconcat = reqack.macros.deconcat;

module.exports = {
    lzc: lzc,
    normalize: {
        data: p => `// node:${p.id} normalize (reciprocal)

//wire [2:0] shift${p.id}_0,shift${p.id}_1,shift${p.id}_2;
//wire [15:0] val${p.id}_0,val${p.id}_1,val${p.id}_2;

//assign val${p.id}_0   = ${p.t[0].wire}[14]?${p.t[0].wire}>>1:${p.t[0].wire};
//assign shift${p.id}_0 = ${p.t[0].wire}>4?3'b1:0;

//assign val${p.id}_1   = val${p.id}_0>2?val${p.id}_0>>2:val${p.id}_0;
//assign shift${p.id}_1 = val${p.id}_0>2?shift${p.id}_0+3'b10:shift${p.id}_0;

//assign val${p.id}_2   = val${p.id}_1>1?val${p.id}_1>>1:val${p.id}_1;
//assign shift${p.id}_2 = val${p.id}_1>1?shift${p.id}_1+3'b1:shift${p.id}_1;

assign ${p.i[0].wire} = (${p.i[1].width}'d${p.t[0].m} >= ${p.t[1].wire}) ? ${p.t[0].wire} >> (${p.i[1].width}'d${p.t[0].m}-${p.t[1].wire}) :
 ${p.t[0].wire} << (${p.t[1].wire} - ${p.i[1].width}'d${p.t[0].m});
assign ${p.i[1].wire} = ${p.i[1].width}'d${p.t[0].m}-${p.t[1].wire};
`
    },

    lhsOp: {
        data: p => `assign ${p.i[0].wire} = ${p.i[0].op} ${p.t[0].wire};`
    },
    rhsOp: {
        data: p => `assign ${p.i[0].wire} = ${p.t[0].wire} ${p.i[0].op};`
    },
    bitSelect: {
        data: p => `assign ${p.i[0].wire} = ${p.t[0].wire}[${p.i[0].highSelect}:${p.i[0].lowSelect}]; //${JSON.stringify(p.i[0])}`
    },
    reciprocalSatShift2:{
        data: p => `assign ${p.i[0].wire} = |${p.t[0].wire}[${p.t[0].width-1}:${p.t[0].width-2}] ? ${p.t[0].width}'d${Math.pow(2, p.t[0].width-1)-1} : ${p.t[0].wire} << 2;`
    },
    reciprocalSat: {
        data: p => `assign ${p.i[0].wire} = ${p.t[0].wire}[${p.t[0].width-1}]?  ${p.t[0].width}'d${Math.pow(2, p.t[0].width-1)-1}:${p.t[0].wire};`
    },

    renorm: {
        data: p => `// node: ${p.id} renorm

assign ${p.i[0].wire} = ${p.t[1].wire}[${p.t[1].width-1}] ?   ${p.t[0].wire} << (~${p.t[1].wire} + 1'b1) : ${p.t[0].wire} >> ${p.t[1].wire};

//assign ${p.i[0].wire} = ${p.t[0].wire}[15:0] >> ${p.t[0].wire}[19:16];
`
    },
    funnel: {
        // ctrl: p => `funnel_ctrl unode${p.id} ();`,
        ctrl2data: p => [
            ['sel',  'nsel'  + p.id,  8],
            ['mode', 'nmode' + p.id, -8]
        ]
    },
    defunnel: {
        // ctrl: p => `defunnel_ctrl unode${p.id} ();`,
        ctrl2data: p => {
            const targets = (p.t || []).length;
            // console.log(JSON.stringify(p, null, 4), targets);
            return [
                ['enable',  'enable' + p.id, 2 * (targets - 1)],
                ['mode', 'mode' + p.id, -8]
            ];
        }
    },
    bs: {
        ctrl: p => `// node:${p.id} bs
assign req${p.i[0]} = req${p.t[0]};
assign ack${p.t[0]} = ack${p.i[0]};
assign ack${p.t[1]} = 1'b1;`

    },
    round_sat: {
    },
    addsub: {
        ctrl: p => `// node:${p.id} addsub
assign ack${p.t[1]} = 1'b1;
reg req${p.i[0]}_r;
assign req${p.i[0]} = req${p.i[0]}_r;
assign n${p.id}_en = req${p.t[0]} & ack${p.t[0]}; //${p.t.valid} & ${p.t.ready};
assign ack${p.t[0]} = ~req${p.i[0]}_r | ack${p.i[0]};
always @(posedge clk or negedge reset_n) if (~reset_n) req${p.i[0]}_r <= 1'b0; else req${p.i[0]}_r <= ~ack${p.t[0]} | req${p.t[0]};`,
        data: p => {
            const width = p.t[0].width;
            const lhs = `${p.t[0].wire}[${width - 1}:${width / 2}]`;
            const rhs = `${p.t[0].wire}[${width / 2 - 1}:0]`;
            // should map to ALU54B primitive
            return `
// assign ${p.i[0].wire} = ${p.t[1].wire}[0] ? (${lhs} - ${rhs}) : (${lhs} + ${rhs});
wire n${p.id}_en;
alu54b_wrapper addsub${p.id} (
    .a(${lhs}),
    .b(${rhs}),
    .c(${p.i[0].wire}),
    .subadd(${p.t[1].wire}),
    .ce(n${p.id}_en),
    .clk(clk),
    .rst(~reset_n)
);
`;
            // return `assign ${p.i[0].wire} = (${lhs} - ${rhs});`;
        },
        ctrl2data: p => [
            ['ene',  'n' + p.id + '_en', 1]
        ]
    },
    deconcat: deconcat,
    slice16: {
        data: p => {
            const rhs = p.t[0].wire;
            const step = 16;
            return p.i.map((sig, sigi) => `assign ${sig.wire} = {{${sig.width - step + 1}{${rhs}[${step * sigi + step - 1}]}}, ${rhs}[${step * sigi + step - 2}:${step * sigi}]};`).join('\n');
        },
        ctrl: forkCtrl // p => JSON.stringify(p, null, 4)
    },
    m2c: {
        data: p => {
            const inputs = p.t.length - 1;
            const selector = p.t[inputs].wire;
            const tedges = p.i[0].edges || [1, 1, 1, 1];
            const iw = [0, 1, 2, 3].map(idx =>
                (idx < inputs) ? p.t[idx].wire : tedges[idx]
            );
            return `
// ${JSON.stringify(p.i)}
wire [1:0] n${p.id}sel; assign n${p.id}sel = ${selector};
assign ${p.i[0].wire} =
    (n${p.id}sel == 2'b00) ? ${iw[0]} :
    (n${p.id}sel == 2'b01) ? ${iw[1]} :
    (n${p.id}sel == 2'b10) ? ${iw[2]} : ${iw[3]};
`;
        },
        ctrl: p => {
            const inputs = p.t.length - 1;
            const selector = p.t[inputs];
            const iw = [0, 1, 2, 3].map(idx =>
                (idx < inputs) ? 'req' + p.t[idx] : '1'
            );
            const acks = range(inputs).map(idx =>
                `assign ack${p.t[idx]} = (n${p.id}sel != ${idx}) | ack${p.i[0]};`
            );
            return `// node:${p.id} m2c
assign req${p.i[0]} =
    (n${p.id}sel == 2'b00) ? ${iw[0]} :
    (n${p.id}sel == 2'b01) ? ${iw[1]} :
    (n${p.id}sel == 2'b10) ? ${iw[2]} : ${iw[3]};
${acks.join('\n')}
assign ack${selector} = 1'b1;
`;
        },
        ctrl2data: p => [
            ['sel', 'n' + p.id + 'sel', -2]
        ]
    }
};
