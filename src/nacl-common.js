// Modified in 2021 by Gregor Mitscha-Baude.
// Ported in 2014 by Dmitry Chestnykh and Devi Mandiri.
// Public domain.
//
// Implementation derived from TweetNaCl version 20140427.
// See for details: http://tweetnacl.cr.yp.to/
export {
  naclRandomBytes,
  randombytes,
  checkArrayTypes,
  cleanup,
  crypto_verify_32,
};

function naclRandomBytes(n) {
  let b = new Uint8Array(n);
  randombytes(b, n);
  return b;
}

let QUOTA = 65536;
function randombytes(x, n) {
  let v = new Uint8Array(n);
  for (let i = 0; i < n; i += QUOTA) {
    crypto.getRandomValues(v.subarray(i, i + Math.min(n - i, QUOTA)));
  }
  for (let i = 0; i < n; i++) x[i] = v[i];
  cleanup(v);
}

// constant-time comparison of two integer arrays
function crypto_verify_32(x, xi, y, yi) {
  return vn(x, xi, y, yi, 32);
}

function vn(x, xi, y, yi, n) {
  let d = 0;
  for (let i = 0; i < n; i++) d |= x[xi + i] ^ y[yi + i];
  return (1 & ((d - 1) >>> 8)) - 1;
}

function checkArrayTypes() {
  for (let i = 0; i < arguments.length; i++) {
    if (!(arguments[i] instanceof Uint8Array))
      throw new TypeError('unexpected type, use Uint8Array');
  }
}

function cleanup(arr) {
  for (let i = 0; i < arr.length; i++) arr[i] = 0;
}
