export {sign, verify, newKeyPair, keyPairFromSeed, keyPairFromSecretKey};

/**
 * Sign a message with your secret key. Returns a 64 byte signature. Async version of `nacl.sign.detached`.
 */
declare function sign(
  message: Uint8Array,
  secretKey: Uint8Array
): Promise<Uint8Array>;

/**
 * Verifies the signature, returns true if and only if it is valid. Async version of `nacl.sign.detached.verify`.
 */
declare function verify(
  message: Uint8Array,
  signature: Uint8Array,
  publicKey: Uint8Array
): Promise<boolean>;

/**
 * Creates a new, random key pair. Async version of `nacl.sign.keyPair`.
 */
declare function newKeyPair(): Promise<{
  secretKey: Uint8Array;
  publicKey: Uint8Array;
}>;

/**
 * Deterministically creates a key pair from a 32-byte seed. Async version of `nacl.sign.keyPair.fromSeed`.
 */
declare function keyPairFromSeed(
  seed: Uint8Array
): Promise<{secretKey: Uint8Array; publicKey: Uint8Array}>;

/**
 * Re-creates the full key pair from the 64-byte secret key (which, in fact, has the public key stored in its last 32 bytes).
 * Async version of `nacl.sign.keyPair.fromSecretKey`.
 */
declare function keyPairFromSecretKey(
  secretKey: Uint8Array
): Promise<{secretKey: Uint8Array; publicKey: Uint8Array}>;
