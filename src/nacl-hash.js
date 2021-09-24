export {hashNative};

// TODO get running in node without runtime checks
async function hashNative(msg) {
  if (typeof crypto === 'undefined') {
    // let crypto = await import('node:crypto');
    // let hash = new Uint8Array(crypto.createHash('sha512').update(msg).digest());
    // // console.log(hash);
    // return hash;
  } else {
    return new Uint8Array(await crypto.subtle.digest('SHA-512', msg));
  }
}
