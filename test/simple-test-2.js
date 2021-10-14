import nacl from 'tweetnacl';
import {sign, verify} from '../src/sign.wat.js';
import {toBytes, toBase64} from 'fast-base64';
import {fromUrl} from 'fast-base64/url';
import identity from './identity2.js';

let message = await createBytesToSign(identity.info, 1634196940);
let secretKey = await toBytes(fromUrl(identity.secretKey));
let publicKey = await toBytes(fromUrl(identity.publicKey));

let signature = await sign(message, secretKey);
let signatureNacl = nacl.sign.detached(message, secretKey);

console.log(await toBase64(signature));
console.log(await toBase64(signatureNacl));

console.log(await verify(message, signature, publicKey));
console.log(nacl.sign.detached.verify(message, signatureNacl, publicKey));

// -----------------------------

async function createBytesToSign(data, expiration) {
  let payload = await toBase64(new TextEncoder().encode(JSON.stringify(data)));
  let versionBytes = new Uint8Array(4);
  let expirationBytes = new Uint8Array(8);
  let keyTypeBytes = new TextEncoder().encode('ed25519');
  let payloadBytes = await toBytes(payload);
  // let payloadBytes = new TextEncoder().encode(certified);

  // TODO: this is incorrect, n >> 32 is just n >> 0 = n (the shift amount is taken mod 32)
  // Convert the timestamp into a little-endian uint64 representation
  for (let i = 0; i < 8; i++) {
    expirationBytes[i] = (expiration >> (8 * i)) & 0xff;
  }
  return concatBytes(versionBytes, expirationBytes, keyTypeBytes, payloadBytes);
}

function concatBytes(...arrays) {
  if (!arrays.length) return null;
  let totalLength = arrays.reduce((acc, value) => acc + value.length, 0);
  let result = new Uint8Array(totalLength);
  let length = 0;
  for (let array of arrays) {
    result.set(array, length);
    length += array.length;
  }
  return result;
}
