'use strict';

const _ = require('lodash');
const range = _.range;

const lzcZ = (indices) => {
    let logic = indices.map(e => e.join(' & '));
    logic = logic.map(e => '(' + e + ')');
    logic = logic.join(' | ');
    return logic;
};

const lzcIndices = (wire, width) => {
    let subIndices = [];
    let indices = [];
    for (let i = width - 1; i > 0; i = i - 2) {
    // console.log("here: " + i);
        indices.push(wire + '[' + i + ']');
        for (let j = width - 2; j > i; j = j - 2) {
            indices.push('~' + wire + '[' + j + ']');
        }
        subIndices.push(indices);
        indices = [];
    }
    return subIndices;
};

const nxtStageLogic = (wire, width) => {
    let logic = [];
    for(let i = width - 2; i >= 0; i = i - 2) {
        logic.push(wire + '[' + i + '] | ' + wire + '[' + (i + 1) + ']');
    }
    return '{' + logic.join(',') + '}';
};

const lzcLogic = (twire, iwire, node, width, n) => {
    const log2w = Math.log2(width);
    const stage = 'stage' + node + '_';
    return `
//node:${node} leading zeros counter

wire [${width-1}:0] pad_signal${node};
assign pad_signal${node} = ${twire}; //|${width}'d${Math.pow(2, n)-1};

${
    range(log2w)
        .map(i => `wire[${(width / Math.pow(2, i)) - 1}:0] ${stage + i};`)
        .join('\n')
}

${
    range(log2w)
        .map(i => (i == 0)
            ? `assign ${stage + i} = pad_signal${node};`
            : `assign ${stage + i} = ${nxtStageLogic(stage + (i - 1), width / Math.pow(2, i - 1))};`)
        .join('\n')
}

wire[${Math.log2(width)}:0] lzc${node};

${
    range(log2w + 1)
        .map(i => (i < log2w)
            ? `assign lzc${node}[${i}] = ~(${lzcZ(lzcIndices(stage + i, width / Math.pow(2, i)))});`
            : `assign lzc${node}[${i}] = ~(|pad_signal${node});`)
        .join('\n')
}

assign ${iwire} = lzc${node};
`;

};

exports.data = p => lzcLogic(p.t[0].wire, p.i[0].wire, p.id, p.t[0].width, p.t[0].n);
