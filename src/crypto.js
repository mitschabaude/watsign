export {randomBytes, hashNative};

function randomBytes(n) {
  return crypto.getRandomValues(new Uint8Array(n));
}

async function hashNative(msg) {
  return new Uint8Array(await crypto.subtle.digest('SHA-512', msg));
}
