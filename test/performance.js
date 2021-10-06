import {run} from 'chrode';

await run('./test/test-watsign.js');
await sleep(4);
await run('./test/test-tweetnacl-js.js');
await sleep(4);
await run('./test/test-noble-ed25519.js');

function sleep(n) {
  return new Promise(r => setTimeout(r, n * 1000));
}
