import perf from './perf.js';
import identity from './identity.js';
import {toBase64, toBytes} from 'fast-base64';
import {fromUrl, toUrl} from 'fast-base64/url';
import {createBytesToSign} from './helper.js';

import {sign, verify, getPublicKey} from 'noble-ed25519';

let secretKey = (await toBytes(fromUrl(identity.secretKey))).slice(0, 32);
let publicKey = await toBytes(fromUrl(identity.publicKey));
let longMessage = await createBytesToSign(identity.info);
let shortMessage = await createBytesToSign({});

perf('noble-ed25519', async start => {
  let stop = start('sign (short msg)');
  let signature = await sign(shortMessage, secretKey);
  stop();

  stop = start('verify (short msg)');
  let ok = await verify(signature, shortMessage, publicKey);
  stop();

  if (!ok) console.error('ERROR: verify failed');

  stop = start('sign (long msg)');
  signature = await sign(longMessage, secretKey);
  stop();

  if (
    (await toBase64(signature)) !==
    'v6euinmjEOkHHwArp/nHA18stpd9swkZ6f1/tWz6Y0bqHTgU+S2WE9JPHElpwiMLV7G/xElEpBE8656GgA2gCw=='
  ) {
    console.error('signature not equal');
    console.log(await toBase64(signature));
  }

  stop = start('verify (long msg)');
  ok = await verify(signature, longMessage, publicKey);
  stop();

  if (!ok) console.error('ERROR: verify failed');
});

// check correctness of public key
let derivedPublicKey = await getPublicKey(secretKey);
if (toUrl(await toBase64(derivedPublicKey)) !== identity.publicKey) {
  console.error('keys not equal');
}
