// Ported in 2021 by Gregor Mitscha-Baude.
// Ported in 2014 by Dmitry Chestnykh and Devi Mandiri.
// Public domain.
//
// Implementation derived from TweetNaCl version 20140427.
// See for details: http://tweetnacl.cr.yp.to/

import {
  scalarbasePack,
  reduce,
  signPt2,
  signVerifyFromHash,
  signPublicKeyFromHash,
} from './wat-old/sign.wat';
// import {wrap} from './wrap-wasm-bytes-only.ts';
import {concat} from './util.js';
import {checkArrayTypes, randombytes} from './nacl-common.js';
import {hashNative} from './nacl-hash.js';

export {
  naclSign,
  naclSignVerify,
  naclSignKeyPairFromSecretKey,
  naclSignKeyPair,
  naclSignKeyPairFromSeed,
  sign_BYTES,
  sign_PUBLICKEYBYTES,
  sign_SECRETKEYBYTES,
  sign_SEEDBYTES,
};

const sign_BYTES = 64,
  sign_PUBLICKEYBYTES = 32,
  sign_SECRETKEYBYTES = 64,
  sign_SEEDBYTES = 32;

async function naclSign(msg, secretKey) {
  checkArrayTypes(msg, secretKey);
  if (secretKey.length !== sign_SECRETKEYBYTES)
    throw new Error('bad secret key size');
  return await sign(msg, secretKey);
}

async function naclSignVerify(message, signature, publicKey) {
  checkArrayTypes(message, signature, publicKey);
  if (signature.length !== sign_BYTES) throw new Error('bad signature size');
  if (publicKey.length !== sign_PUBLICKEYBYTES)
    throw new Error('bad public key size');
  return await signVerify(message, signature, publicKey);
}

async function naclSignKeyPair() {
  let sk = new Uint8Array(sign_SECRETKEYBYTES);
  let pk = await signKeypair(sk);
  return {publicKey: pk, secretKey: sk};
}

function naclSignKeyPairFromSecretKey(secretKey) {
  checkArrayTypes(secretKey);
  if (secretKey.length !== sign_SECRETKEYBYTES)
    throw new Error('bad secret key size');
  let pk = new Uint8Array(sign_PUBLICKEYBYTES);
  for (let i = 0; i < pk.length; i++) pk[i] = secretKey[32 + i];
  return {publicKey: pk, secretKey: new Uint8Array(secretKey)};
}

async function naclSignKeyPairFromSeed(seed) {
  checkArrayTypes(seed);
  if (seed.length !== sign_SEEDBYTES) throw new Error('bad seed size');
  let sk = new Uint8Array(sign_SECRETKEYBYTES);
  for (let i = 0; i < 32; i++) sk[i] = seed[i];
  let pk = await signKeypair(sk, true);
  return {publicKey: pk, secretKey: sk};
}

async function sign(msg, secretKey) {
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

async function signVerify(message, signature, publicKey) {
  if (message.length < 0) return false; // ???
  let noncePoint = signature.subarray(0, 32);
  let sig = signature.subarray(32);
  let bigHash = await hashNative(concat(noncePoint, publicKey, message));
  return await signVerifyFromHash(bigHash, noncePoint, sig, publicKey);
}

async function signKeypair(secretKey, seeded) {
  if (!seeded) randombytes(secretKey, 32);
  let secretHash = await hashNative(secretKey.subarray(0, 32));
  let secretScalar = secretHash.subarray(0, 32); // a
  let pk = await signPublicKeyFromHash(secretScalar);
  secretKey.set(pk, 32);
  return pk;
}
