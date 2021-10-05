// deno export
export {
  keyPairFromSecretKey,
  keyPairFromSeed,
  newKeyPair,
  sign,
  verify,
} from './dist/nacl-sign.deno.js';
