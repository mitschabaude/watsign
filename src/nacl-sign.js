import {
  scalarbasePack,
  reduce,
  signPt2,
  verify,
  newKeyPair,
  keyPairFromSecretKey,
  keyPairFromSeed,
} from './wat/sign.wat.js';
import {concat, checkArrayTypes, hashNative} from './util.js';

export {sign, verify, newKeyPair, keyPairFromSeed, keyPairFromSecretKey};

async function sign(msg, secretKey) {
  checkArrayTypes(msg, secretKey);
  if (secretKey.length !== 64) throw new Error('bad secret key size');
  // secretKey = [secret, publicKey], where
  // publicKey = A := a * B, where a = hash(secret)[0:32]
  let secret = secretKey.subarray(0, 32);
  let publicKey = secretKey.subarray(32); // A
  let secretHash = await hashNative(secret);
  let secretScalar = secretHash.subarray(0, 32); // a
  let nonceSeed = secretHash.subarray(32);

  // compute nonce r = hash(hash(secret)[32:], msg) mod L
  // and curve point R = r * B
  let toBeHashed = new Uint8Array(64 + msg.byteLength);
  toBeHashed.set(nonceSeed, 32);
  toBeHashed.set(msg, 64);
  let nonce = await hashNative(toBeHashed.subarray(32));
  nonce = await reduce(nonce); // r
  let noncePoint = await scalarbasePack(nonce); // R

  // H = hash(R, A, msg)
  // sig = S = (r + H*a) mod L
  toBeHashed.set(noncePoint);
  toBeHashed.set(publicKey, 32);
  let bigHash = await hashNative(toBeHashed); // H
  let sig = await signPt2(nonce, secretScalar, bigHash); // S
  // return [R, S]
  return concat(noncePoint, sig);

  // the verifier has the signature [R, S], the public key A, the msg, and the base point B
  // he can re-compute H = hash(R, A, msg) and verify
  // S * B (=== r * B + H * a * B ) === R + H * A
  // constructing S implies knowledge of r, a and thus the secret
}
