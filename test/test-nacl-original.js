import nacl from 'tweetnacl';
import printPerformancePure from './printPerformancePure.js';

async function main() {
  printPerformancePure(
    'nacl-original',
    nacl.sign.detached,
    nacl.sign.detached.verify,
    nacl.sign.keyPair.fromSeed
  );
}
main();
