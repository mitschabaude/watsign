import {
  keyPairFromSecretKey,
  keyPairFromSeed,
  newKeyPair,
  sign,
  verify,
} from '../src/nacl-sign.js';
(async () => {
  let {publicKey, secretKey} = await newKeyPair();
  console.log('publicKey', publicKey);

  let keys = await keyPairFromSeed(secretKey.subarray(0, 32));
  console.log('everything ok?', typedArrayEqual(keys.publicKey, publicKey));

  keys = await keyPairFromSecretKey(secretKey);
  console.log('everything ok?', typedArrayEqual(keys.publicKey, publicKey));

  let message = new TextEncoder().encode('Something I want to sign');
  let signature = await sign(message, secretKey);
  console.log('signature', signature);

  let ok = await verify(message, signature, publicKey);
  console.log('everything ok?', ok);
})();

function typedArrayEqual(arr1, arr2) {
  let n = arr1.length;
  if (arr2.length !== n) return false;
  for (let i = 0; i < n; i++) {
    if (arr1[i] !== arr2[i]) return false;
  }
  return true;
}
