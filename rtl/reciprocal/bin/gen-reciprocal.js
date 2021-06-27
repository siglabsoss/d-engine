#!/usr/bin/env node
'use strict';

const fs = require('fs-extra');

const reciprocal = require('../lib/reciprocal.js');
const macros = require('../lib/datapath-macros');
const reqack = require('reqack');

const g = reqack.circuit('reciprocal');

const s16 = {width: 16};

reciprocal(g)(g()(s16))(g());


fs.outputFile('hdl/reciprocal.dot', reqack.dot(g), () => {
    fs.outputFile('hdl/reciprocal.v', reqack.verilog(g, macros), () => {
        fs.outputFile('hdl/project.js', reqack.manifest(g, 'reciprocal'), () => {});
    });
});
