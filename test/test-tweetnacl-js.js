import perf from './perf.js';
import identity from './identity.js';
import {toBase64, toBytes} from 'fast-base64';
import {fromUrl, toUrl} from 'fast-base64/url';
import {createBytesToSign} from './helper.js';

import nacl from 'tweetnacl';
const sign = nacl.sign.detached;
const verify = nacl.sign.detached.verify;
const keyPairFromSeed = nacl.sign.keyPair.fromSeed;

let secretKey = await toBytes(fromUrl(identity.secretKey));
let publicKey = await toBytes(fromUrl(identity.publicKey));
let longMessage = await createBytesToSign(identity.info);
let shortMessage = await createBytesToSign({});

perf('tweetnacl-js', async start => {
  let stop = start('sign (short msg)');
  let signature = sign(shortMessage, secretKey);
  stop();

  stop = start('verify (short msg)');
  let ok = verify(shortMessage, signature, publicKey);
  stop();

  if (!ok) console.error('ERROR: verify failed');

  stop = start('sign (long msg)');
  signature = sign(longMessage, secretKey);
  stop();

  if (
    (await toBase64(signature)) !==
    'v6euinmjEOkHHwArp/nHA18stpd9swkZ6f1/tWz6Y0bqHTgU+S2WE9JPHElpwiMLV7G/xElEpBE8656GgA2gCw=='
  ) {
    console.error('signature not equal');
    console.log(await toBase64(signature));
  }

  stop = start('verify (long msg)');
  ok = verify(longMessage, signature, publicKey);
  stop();

  if (!ok) console.error('ERROR: verify failed');
});

// check correctness of public key
let {publicKey: derivedPublicKey} = keyPairFromSeed(secretKey.slice(0, 32));
if (toUrl(await toBase64(derivedPublicKey)) !== identity.publicKey) {
  console.error('keys not equal');
}
