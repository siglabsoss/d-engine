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
  it('Check Length', function () {
    this.timeout(10000); // Set timeout to expected run time of the test in ms
    //let t = jsc.forall(jsc.constant(0), function () {
    const numInputs = 2;
    setup('top');
    dut.func0(0);
    dut.func1(2);
    dut.t0_valid(0);
    dut.i0_ready(0);
    // TODO: customize txn, randomizer, set variables/signals
    target.txArray.push({data: 0xDEADDEAD, isLast: true});
    let din = _.range(1024+16).map((i) => {return {data: i , isLast: false}});
    //target.txArray = target.txArray.concat(din.slice());
    target.txArray = target.txArray.concat(trunk_txn.txn({type: 'vcordic'}).slice());
    target.txArray = target.txArray.concat(trunk_txn.txn({type: 'reciprocal'}).slice());

    initiator.randomize = 1;
    target.randomize = 1;
    
    sim.addTask( () => {
      try {
	assert(initiator.rxArray.length == (numInputs*1024*3 + numInputs*16))
	for(let i of _.range(numInputs)) {
	  let block = 1024*3+16;
	  let data2str = (data) => {
	    let d = data.map((e) => e.data);
	    return d.join('\n');
	  };
	  //console.log('here');
	  //console.log(initiator.rxArray.slice(i*block,1023 + i*block).join('\n'));
	  fs.writeFileSync('logs/input_' + i + '.dat', data2str(initiator.rxArray.slice(i*block,1023 + i*block)));
	  fs.writeFileSync('logs/func0_' + i + '.dat', data2str(initiator.rxArray.slice(i*block+1024, 1023 + i*block+1024)));
	  fs.writeFileSync('logs/func1_' + i + '.dat', data2str(initiator.rxArray.slice(i*block+2*1024, 1023 + i*block+2*1024)));
	}
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
  });
});

