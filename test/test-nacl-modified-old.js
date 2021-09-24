import {
  naclSignVerify,
  naclSign,
  naclSignKeyPairFromSeed,
} from '../src-experiments/nacl-sign-old.js';
import printPerformancePure from './printPerformancePure.js';

async function main() {
  printPerformancePure(
    'nacl-modified',
    naclSign,
    naclSignVerify,
    naclSignKeyPairFromSeed
  );
}
main();
