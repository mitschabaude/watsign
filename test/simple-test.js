import {newKeyPair, sign, verify} from '../src/nacl-sign.js';
(async () => {
  let {publicKey, secretKey} = await newKeyPair();
  let message = new TextEncoder().encode('Something I want to sign');
  let signature = await sign(message, secretKey);
  let ok = await verify(message, signature, publicKey);
  console.log('everything ok?', ok);
})();
