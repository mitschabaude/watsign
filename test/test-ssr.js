import base64 from 'compact-base64';
import ssr from 'simple-signed-records-engine';
import printPerformance from './printPerformance';

// 140ms, 40ms
printPerformance('ssr', signData, verifyData);

function signData(identity, data) {
  return ssr.sign({
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
  let verifiedRecord = ssr.data(record);
  if (!verifiedRecord) return;
  let {identities, data} = verifiedRecord;
  if (!identities.includes(base64.urlToOriginal(key))) return;
  return data;
}

function decode(base64String) {
  return Uint8Array.from(base64.decodeUrl(base64String, 'binary'));
}
