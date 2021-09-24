import {naclSignKeyPair, naclSign, naclSignVerify} from '../src/nacl-sign.js';
(async () => {
  let {publicKey, secretKey} = await naclSignKeyPair();
  let message = new Uint8Array([1, 2, 3, 4, 5, 6, 7, 8]);
  let signature = await naclSign(message, secretKey);
  let ok = await naclSignVerify(message, signature, publicKey);
  console.log('ok', ok);
})();
