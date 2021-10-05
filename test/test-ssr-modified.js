import {
  naclSignVerify,
  naclSign,
  naclSignKeyPairFromSeed,
} from '../dist/nacl-sign.js';
import {toBytes, toBase64} from 'fast-base64';
import {fromUrl, toUrl} from 'fast-base64/url';
import printPerformance from './printPerformance.js';
import {concat} from '../src/util.js';

// 4.5ms, 5.5ms
async function main() {
  printPerformance('nacl-modified', sign, verify, createKeys);
}
main();

async function createKeys(seed) {
  let {publicKey, secretKey} = await naclSignKeyPairFromSeed(seed);
  return {
    publicKey: toUrl(await toBase64(publicKey)),
    secretKey: toUrl(await toBase64(secretKey)),
  };
}

async function sign({publicKey, secretKey}, data) {
  // let start;
  // start = performance.now();
  publicKey = await toBytes(fromUrl(publicKey));
  secretKey = await toBytes(fromUrl(secretKey));
  // console.log(
  //   `decode base64 keys: ${(performance.now() - start).toFixed(2)} ms`
  // );

  // start = performance.now();
  const certified = JSON.stringify(data);
  // console.log(`JSON stringify: ${(performance.now() - start).toFixed(2)} ms`);

  // const expiration = 300 + Math.floor(new Date().getTime() / 1000.0);
  const expiration = 1626121765;

  // start = performance.now();
  const bytesToSign = await createBytesToSign({expiration, certified});
  // console.log(
  //   `textencode / hash / concat: ${(performance.now() - start).toFixed(2)} ms`
  // );

  // start = performance.now();
  const signatureBytes = await naclSign(bytesToSign, secretKey);
  // console.log(`nacl.sign: ${(performance.now() - start).toFixed(2)} ms`);

  // start = performance.now();
  const signature = {
    key: await toBase64(publicKey),
    payload: await toBase64(signatureBytes),
  };
  // console.log(`encode base64: ${(performance.now() - start).toFixed(2)} ms`);

  return {expiration, certified, signature};
}

async function verify({expiration, certified, signature}, key) {
  let ok = false;
  if (signature.key !== fromUrl(key)) return;
  try {
    const bytesToSign = await createBytesToSign({expiration, certified});
    let signatureBytes = await toBytes(signature.payload);
    let publicKey = await toBytes(signature.key);
    ok = await naclSignVerify(bytesToSign, signatureBytes, publicKey);
  } catch (e) {
    console.log('error verifying', e);
    return;
  }
  if (!ok) return;

  return JSON.parse(certified);
}

async function createBytesToSign({expiration, certified}) {
  const expirationBytes = new Uint8Array([0, 0, 0, 0, 0, 0, 0, 0]);
  let payloadBytes = new TextEncoder().encode(certified);
  // payloadBytes = new Uint8Array(
  //   await crypto.subtle.digest('SHA-512', payloadBytes)
  // );
  // Convert the timestamp into a little-endian uint64 representation
  for (let i = 0; i < 8; i++) {
    expirationBytes[i] = (expiration >> (8 * i)) & 0xff;
  }
  return concat(expirationBytes, payloadBytes);
}
