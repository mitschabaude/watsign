import {sign, verify, keyPairFromSeed} from '../dist/sign.wat.js';
import printPerformancePure from './printPerformancePure.js';

async function main() {
  printPerformancePure('watsign', sign, verify, keyPairFromSeed);
}
main();
