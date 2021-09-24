export {hashNative};

// TODO get running in node without runtime checks, probably by a branching build step

async function hashNative(msg) {
  return new Uint8Array(await crypto.subtle.digest('SHA-512', msg));
}

// async function hashNativeNode(msg) {
//   let crypto = await import('node:crypto');
//   return new Uint8Array(crypto.createHash('sha512').update(msg).digest());
// }
