import {run} from 'chrode';

let scripts = [
  // './test-ssr-modified.js',
  // './test-ssr-prehash.js',
  // './test-ssr-no-buffer.js',
  // './test-ssr.js',
];

await run('./test/test-nacl-modified.js', {wasmWrap: true});
await sleep1();
await run('./test/test-nacl-original.js');
await sleep1();

for (let s of scripts) {
  await run(s);
  await sleep1();
}

// console.log('done');

function sleep1() {
  return new Promise(r => setTimeout(r, 4000));
}
