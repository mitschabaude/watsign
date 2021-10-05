import crypto from 'node:crypto';

export {randomBytes, hashNative};

function randomBytes(n) {
  return new Uint8Array(crypto.randomBytes(n));
}

// async to match Web Crypto signature
async function hashNative(msg) {
  return new Uint8Array(crypto.createHash('sha512').update(msg).digest());
}
