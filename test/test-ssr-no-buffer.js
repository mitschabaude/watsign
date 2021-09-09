import base64 from 'compact-base64';
import nacl from 'tweetnacl';
import {decodeBase64, encodeBase64} from 'tweetnacl-util';
import printPerformance from './printPerformance';

// 110ms, 30ms
printPerformance('ssr-no-buffer', signData, verifyData);

function signData(identity, data) {
  return sign({
    record: data,
    keypair: {
      secretKey: decode(identity.secretKey),
      publicKey: decode(identity.publicKey),
    },
    // validSeconds: 300,
    validUntil: 1626121765,
  });
}

function verifyData(record, key) {
  if (!verify(record)) return;
  let identities = record.Signatures.map(s => s.Identity);
  if (!identities.includes(base64.urlToOriginal(key))) return;

  return JSON.parse(record.Certified);
}

function sign({record, keypair, validSeconds, validUntil}) {
  const Certified = JSON.stringify(record);
  const Expiration =
    validUntil ||
    (validSeconds || 1800) + Math.floor(new Date().getTime() / 1000.0);

  const bytesToSign = createBytesToSign({Expiration, Certified});

  return {
    Version: 0,
    Expiration,
    Certified,
    Signatures: [createSignature(bytesToSign, keypair)],
  };
}

function verify(ssr) {
  try {
    const bytesToSign = createBytesToSign(ssr);
    if (ssr.Version !== 0) {
      return false;
    }
    return ssr.Signatures.map(signature =>
      nacl.sign.detached.verify(
        bytesToSign,
        decodeBase64(signature.Payload),
        decodeBase64(signature.Identity)
      )
    ).every(s => s);
  } catch (e) {
    return false;
  }
}

function createSignature(bytesToSign, keypair) {
  const signatureBytes = nacl.sign.detached(bytesToSign, keypair.secretKey);
  const signature = encodeBase64(signatureBytes);
  return {
    Identity: encodeBase64(keypair.publicKey),
    Payload: signature,
  };
}

function createBytesToSign({Expiration, Certified}) {
  const expirationBytes = new Uint8Array([0, 0, 0, 0, 0, 0, 0, 0]);
  const payloadBytes = new TextEncoder().encode(Certified);
  // Convert the timestamp into a little-endian uint64 representation
  for (let i = 0; i < 8; i++) {
    expirationBytes[i] = (Expiration >> (8 * i)) & 0xff;
  }
  return concat(expirationBytes, payloadBytes);
}

function decode(base64String) {
  return Uint8Array.from(base64.decodeUrl(base64String, 'binary'));
}

function concat(...arrays) {
  if (!arrays.length) return null;

  let totalLength = arrays.reduce((acc, value) => acc + value.length, 0);
  let result = new Uint8Array(totalLength);

  let length = 0;
  for (let array of arrays) {
    result.set(array, length);
    length += array.length;
  }

  return result;
}
