// Modified in 2021 by Gregor Mitscha-Baude.
// Ported in 2014 by Dmitry Chestnykh and Devi Mandiri.
// Public domain.
//
// Implementation derived from TweetNaCl version 20140427.
// See for details: http://tweetnacl.cr.yp.to/

/* Arithmetic modulo the prime 2^255 - 19 */
// integers in Z_p are internally represented as Float64Array(16)
// unpack25519, pack25519 are conversion functions to external representation as Uint8Array(32)
// the remaining functions operate on one or more Float64Array(16)

import {crypto_verify_32} from './nacl-common.js';

export {
  set25519,
  car25519,
  sel25519,
  pack25519,
  unpack25519,
  add25519,
  sub25519,
  mul25519,
  square25519,
  inv25519,
  neq25519,
  par25519,
};

// convert external Uint8Array(32) to internal Float64Array(16)
function unpack25519(o, n) {
  for (let i = 0; i < 16; i++) o[i] = n[2 * i] + (n[2 * i + 1] << 8);
  o[15] &= 0x7fff;
}

// convert internal Float64Array(16) to external Uint8Array(32)
function pack25519(out, n) {
  let i, j, b;
  let m = new Float64Array(16);
  let t = new Float64Array(16);
  for (i = 0; i < 16; i++) t[i] = n[i];
  car25519(t);
  car25519(t);
  car25519(t);
  for (j = 0; j < 2; j++) {
    m[0] = t[0] - 0xffed;
    for (i = 1; i < 15; i++) {
      m[i] = t[i] - 0xffff - ((m[i - 1] >> 16) & 1);
      m[i - 1] &= 0xffff;
    }
    m[15] = t[15] - 0x7fff - ((m[14] >> 16) & 1);
    b = (m[15] >> 16) & 1;
    m[14] &= 0xffff;
    sel25519(t, m, 1 - b);
  }
  for (i = 0; i < 16; i++) {
    out[2 * i] = t[i] & 0xff;
    out[2 * i + 1] = t[i] >> 8;
  }
}

function set25519(r, a) {
  for (let i = 0; i < 16; i++) r[i] = a[i] | 0;
}

function car25519(o) {
  let c = 1;
  for (let i = 0; i < 16; i++) {
    let v = o[i] + c + 65535;
    c = Math.floor(v / 65536);
    o[i] = v - c * 65536;
  }
  o[0] += c - 1 + 37 * (c - 1);
}

function sel25519(p, q, b) {
  let c = ~(b - 1);
  for (let i = 0; i < 16; i++) {
    let t = c & (p[i] ^ q[i]);
    p[i] ^= t;
    q[i] ^= t;
  }
}

function neq25519(a, b) {
  let c = new Uint8Array(32);
  let d = new Uint8Array(32);
  pack25519(c, a);
  pack25519(d, b);
  return crypto_verify_32(c, 0, d, 0);
}

function par25519(a) {
  let d = new Uint8Array(32);
  pack25519(d, a);
  return d[0] & 1;
}

function add25519(o, a, b) {
  for (let i = 0; i < 16; i++) o[i] = a[i] + b[i];
}

function sub25519(o, a, b) {
  for (let i = 0; i < 16; i++) o[i] = a[i] - b[i];
}

// multiplication mod 2^255 - 19
// the original nacl-fast.js uses an unrolled version
function mul25519(out, a, b) {
  let i, j;
  let t = new Float64Array(31);
  for (i = 0; i < 31; i++) t[i] = 0;
  for (i = 0; i < 16; i++) {
    for (j = 0; j < 16; j++) {
      t[i + j] += a[i] * b[j];
    }
  }
  for (i = 0; i < 15; i++) {
    t[i] += 38 * t[i + 16];
  }
  for (i = 0; i < 16; i++) out[i] = t[i];
  car25519(out);
  car25519(out);
}

function square25519(o, a) {
  mul25519(o, a, a);
}

function inv25519(o, i) {
  let c = new Float64Array(16);
  let a;
  for (a = 0; a < 16; a++) c[a] = i[a];
  for (a = 253; a >= 0; a--) {
    square25519(c, c);
    if (a !== 2 && a !== 4) mul25519(c, c, i);
  }
  for (a = 0; a < 16; a++) o[a] = c[a];
}
