const dut = require('../build/Release/dut.node');
const {Sim, SimUtils, RisingEdge, RisingEdges, FallingEdge, FallingEdges, Edge, Edges, Interfaces} = require('signalflip-js');
const { Clock } = SimUtils;
const {Elastic} = Interfaces;
const _ = require('lodash');
const fs = require('fs');

const jsc = require('jsverify');
const assert = require('assert');

const trunk_txn = require('../transactions/trunk_txn');

let sim;

const nameToNum = {
  'vcordic' : 0,
  'rcordic' : 1,
  'reciprocal' : 2,
};

const numToName = {
  0: 'vcordic',
  1: 'rcordic',
  2: 'reciprocal'
};


function printHex(x, joy = '\n', title = undefined) {
  if( typeof x[Symbol.iterator] !== 'function' ) {
    x = [x];
  }
  let asStr = x.map( (y) => {
    const ln = ((y&0xffffffff)>>>0).toString(16);
    const leftpad = '0'.repeat(8-ln.length);
    return leftpad + ln;
  } ).join(joy);

  if(typeof title !== 'undefined') {
    console.log(title+asStr);
  } else {
    console.log(asStr);
  }
}

function stripLast(data) {
  let d = data.map((e) => { return e.data });
  return d;
}

let data2str = (data) => {
  let d = data.map((e) => {
    const x = e.data;
    const line = ((x&0xffffffff)>>>0).toString(16);
    const leftpad = '0'.repeat(8-line.length);
    return ''+leftpad+line;
  });
  return d.join('\n');
};



describe('Basic Group', () => {
  let setup = (name) => {
    // set up the environment
    dut.init(name); // Init dut
    sim = new Sim(dut, dut.eval);

    // TODO: Create clock
    let clk = new Clock(dut.clk, 1)
    sim.addClock(clk);

    // RESET
    sim.addTask(function* () {
      dut.srst(1);
      yield* RisingEdges(dut.clk, 5);
      dut.srst(0);
      yield* RisingEdge(dut.clk);
    }(), 'RESET');
    
    // TODO: Add setup code (interfaces, transaction, ...) etc...
    target = new Elastic(sim, 0, dut.clk, dut.t0_data, dut.t0_valid, dut.t0_ready, dut.t0_last);
    initiator = new Elastic(sim, 1, dut.clk, dut.i0_data, dut.i0_valid, dut.i0_ready, dut.i0_last);
    target.randomizeValid = ()=>{ return jsc.random(0,5); };
    initiator.randomizeReady = ()=>{ return jsc.random(0,5); };
    target.init();
    initiator.init();

    // TODO: Add post_run tasks (test checking)
    // sim.addTask(() => { /* post_run function */}, 'POST_RUN');

  };
  it('Check Length Single Function', function () {
    this.timeout(10000); // Set timeout to expected run time of the test in ms
    //let t = jsc.forall(jsc.constant(0), function () {

    const numFunctions = (1+1); // how many output functions are there, the original counts as one

    const numInputs = 1;
    setup('top');

    // Set the functions
    dut.func0(0);
    dut.func1(1);

    // Setup inputs
    dut.t0_valid(0);
    dut.i0_ready(0);

    // Push a single word with last to "line up" D-Engine
    target.txArray.push({data: 0xDEADDEAD, isLast: true});

    // alternate input
    // let din = _.range(1024+16).map((i) => {return {data: i , isLast: false}});
    //target.txArray = target.txArray.concat(din.slice());

    let txn1 = trunk_txn.txn({type: 'vcordic'}).slice();
    let trunk1 = stripLast(txn1).slice(-16);
    target.txArray = target.txArray.concat(txn1);

    // let txn2 = trunk_txn.txn({type: 'rcordic'}).slice();
    // let trunk2 = stripLast(txn2).slice(-16);
    // target.txArray = target.txArray.concat(txn2);


    let inputTrunks = [trunk1];

    // printHex(trunk1);
    // printHex(trunk2);

    initiator.randomize = 1;
    target.randomize    = 1;
    
    sim.addTask( () => {
      try {
        assert(initiator.rxArray.length == (numInputs*1024*numFunctions + numInputs*16))
        for(let i of _.range(numInputs)) {
          let block = 1024*numFunctions+16;

          //console.log('here');
          //console.log(initiator.rxArray.slice(i*block,1023 + i*block).join('\n'));
          fs.writeFileSync('logs/input_' + i + '.hex', data2str(initiator.rxArray.slice(i*block,1024 + i*block)));
          fs.writeFileSync('logs/func0_' + i + '.hex', data2str(initiator.rxArray.slice(i*block+1024, 1024 + i*block+1024)));
          // fs.writeFileSync('logs/func1_' + i + '.hex', data2str(initiator.rxArray.slice(i*block+2*1024, 1023 + i*block+2*1024)));

          let trunkOut = initiator.rxArray.slice(1024 + i*block+1*1024, 16 + 1024 + i*block+1*1024);

          fs.writeFileSync('logs/trunk_' + i + '.hex', data2str(trunkOut));

          // compare the first 14 locations of the trunk as d-engine writes
          // error flags to the last 2 locations
          assert.deepEqual(stripLast(trunkOut).slice(0,14), inputTrunks[i].slice(0,14));
        }

        fs.writeFileSync('logs/output.hex', data2str(initiator.rxArray));

      } catch(e) {
        //let numInputs = 2;
        console.log('Length: ' + initiator.rxArray.length);
        console.log('Output Length: ' + ((numInputs*1024*3) + (numInputs*16)));
        
        dut.finish();
        throw(e);
      }
      //console.log(initiator.rxArray.length);
    }, 'POST_RUN');
    sim.run(50000); //run for 1000 ticks
      //return true;
    //});
    //const props = {size: 2000, tests: 200}; //, rngState: "" }; // <- add this parameter to run the test with the seed that caused the error
    //jsc.check(t, props);
  }); // test
  it('Check Length Double Function', function () {
    return;
    this.timeout(10000); // Set timeout to expected run time of the test in ms
    //let t = jsc.forall(jsc.constant(0), function () {
    const numInputs = 2;
    setup('top');

    // Set the functions
    dut.func0(0);
    dut.func1(1);

    // Setup inputs
    dut.t0_valid(0);
    dut.i0_ready(0);

    // Push a single word with last to "line up" D-Engine
    target.txArray.push({data: 0xDEADDEAD, isLast: true});

    // alternate input
    // let din = _.range(1024+16).map((i) => {return {data: i , isLast: false}});
    //target.txArray = target.txArray.concat(din.slice());

    let txn1 = trunk_txn.txn({type: 'vcordic'}).slice();
    let trunk1 = stripLast(txn1).slice(-16);
    target.txArray = target.txArray.concat(txn1);

    let txn2 = trunk_txn.txn({type: 'reciprocal'}).slice();
    let trunk2 = stripLast(txn2).slice(-16);
    target.txArray = target.txArray.concat(txn2);


    let inputTrunks = [trunk1, trunk2];

    // printHex(trunk1);
    // printHex(trunk2);

    initiator.randomize = 0;
    target.randomize    = 0;
    
    sim.addTask( () => {
      try {
        assert(initiator.rxArray.length == (numInputs*1024*3 + numInputs*16))
        for(let i of _.range(numInputs)) {
          let block = 1024*3+16;

          //console.log('here');
          //console.log(initiator.rxArray.slice(i*block,1023 + i*block).join('\n'));
          fs.writeFileSync('logs/input_' + i + '.hex', data2str(initiator.rxArray.slice(i*block,1023 + i*block)));
          fs.writeFileSync('logs/func0_' + i + '.hex', data2str(initiator.rxArray.slice(i*block+1024, 1023 + i*block+1024)));
          fs.writeFileSync('logs/func1_' + i + '.hex', data2str(initiator.rxArray.slice(i*block+2*1024, 1023 + i*block+2*1024)));

          let trunkOut = initiator.rxArray.slice(1024 + i*block+2*1024, 16 + 1024 + i*block+2*1024);

          fs.writeFileSync('logs/trunk_' + i + '.hex', data2str(trunkOut));

          // compare the first 14 locations of the trunk as d-engine writes
          // error flags to the last 2 locations
          assert.deepEqual(stripLast(trunkOut).slice(0,14), inputTrunks[i].slice(0,14));
        }

        fs.writeFileSync('logs/output.hex', data2str(initiator.rxArray));

      } catch(e) {
        //let numInputs = 2;
        console.log('Length: ' + initiator.rxArray.length);
        console.log('Output Length: ' + ((numInputs*1024*3) + (numInputs*16)));
        
        dut.finish();
        throw(e);
      }
      //console.log(initiator.rxArray.length);
    }, 'POST_RUN');
    sim.run(50000); //run for 1000 ticks
      //return true;
    //});
    //const props = {size: 2000, tests: 200}; //, rngState: "" }; // <- add this parameter to run the test with the seed that caused the error
    //jsc.check(t, props);
  }); // test
});

