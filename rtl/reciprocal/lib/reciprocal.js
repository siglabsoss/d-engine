'use strict';
const f2f = require('fixed2float');

const m = 6;
const n = 16-m;
const rs16 = {width: 16, capacity: 1.5, m: 6, n: 16-m};
const rs16_1 = {width: 16, capacity: 1, m: 6, n: 16-m};
const rs32 = {width: 32, capacity: 1};
const s16 = {width: 16};
const bitSelect_s16 = {
    width: 16,
    highSelect: 31 - m,
    lowSelect: 32 - m - 16
};
const const_1p466 = f2f.toFixed(1.466,m,n);
const const_1p0012 = f2f.toFixed(1.0012,m,n);
// const sl_s16 = {width:  16, shiftLeft: 2};
const sub1_s16 = {width: 16, op: '16\'h' + const_1p466.toString(16) + ' -'}; //5dd
const sub1_rs16 = {width: 16, capacity: 1, op: '16\'h' + const_1p466.toString(16) + ' -'}; //401
const sub2_s16 = {width: 16, op: '16\'h' + const_1p0012.toString(16) + ' -'};
const shift1_s16 = {width: 16, op: '<< 2'};
const s5 = {width: 5};
const rs5 = {width: 5, capacity: 1};
const rs5_15 = {width: 5, capacity: 1.5};

module.exports = g => t => {

    const dummy_edge = g('=', t)(rs16);
    const lzc = g('lzc', dummy_edge);
    const norm = g('normalize', dummy_edge);

    lzc(s5)(norm, 'lzc');

    const norm_d = norm(rs16, 'data');
  const norm_s = norm(rs5, 'shift');
  const norm_s_dummy = g('=', norm_s)(rs5);
  const norm_s_dummy2 = g('=', norm_s_dummy)(rs5);
  const sub1 = g('lhsOp', norm_d)
  const sub1_d = sub1(sub1_s16);
  const dummy_1 = g('=', sub1_d)(rs16_1);

    return g('reciprocalSat',
        g('renorm',
            g('reciprocalSatShift2',
                g('bitSelect',
                    g('*',
                        g('lhsOp',
                            g('bitSelect',
                                g('*',
                                    norm_d,
                                    sub1_d
                                )(rs32)
                            )(bitSelect_s16)
                        )(sub2_s16),
                        dummy_1
                    )(rs32)
                )(bitSelect_s16)
            )(shift1_s16),
            norm_s_dummy2
        )(rs16)
    )(rs16);
};
