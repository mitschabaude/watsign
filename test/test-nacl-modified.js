import {sign, verify, keyPairFromSeed} from '../src/nacl-sign.js';
import printPerformancePure from './printPerformancePure.js';

async function main() {
  printPerformancePure('nacl-modified', sign, verify, keyPairFromSeed);
}
main();
