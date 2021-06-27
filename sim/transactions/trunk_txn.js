const _ = require('lodash');
const f2f = require('fixed2float');
let u = (din) => din >>> 0;
function getRandomInt(min, max) {
    return min + Math.floor(Math.random() * Math.floor(max-min+1));
}

function getRandomFromArray(arr) {
    return this[Math.floor(Math.random() * arr.length)];
}
exports.txn = (options = {}) => {

  let {type} = options;
  
  let txn = [];
    
  let length = 1024+16;
  for(let i of _.range(length)) {
    if(i < 1024) {
      if(type == null)
	txn.push({data: u(getRandomInt(0,2^32-1)), isLast: false});
      else if(type == 'vcordic') {
	let x = f2f.toFixed(Math.cos((i/1024)*Math.PI/2),1,15);
	let y = f2f.toFixed(Math.sin((i/1024)*Math.PI/2),1,15);
	let data = (x & 0xFFFF) | ((y & 0xFFFF) << 16);
	txn.push({data: u(data), isLast: false});
      }
      else if(type == 'reciprocal') {
	let data = (i/1024)*0xFFFF;
	//let data = 0x1000;//f2f.toFixed(2, 6, 10);
	txn.push({data: data, isLast: false});
      }
      else if(type == 'rcordic') {
	let data = (i/1024)*0xFFFFFFFF;
	txn.push({data: u(data), isLast: false});
      }
      else {
	console.log('Invalid txn type');
      }
    }
    else
      txn.push({data: i, isLast: false});
  }
  txn[txn.length-1].isLast = true;

  return txn;
}

