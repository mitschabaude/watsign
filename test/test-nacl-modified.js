import {sign, verify, keyPairFromSeed} from '../dist/nacl-sign.js';
import printPerformancePure from './printPerformancePure.js';

async function main() {
  printPerformancePure('watsign', sign, verify, keyPairFromSeed);
}
main();
