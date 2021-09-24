import identity from './identity.js';
import {toBase64, toBytes} from 'fast-base64';
import {fromUrl, toUrl} from 'fast-base64/url';
import {concat} from '../src/util.js';

export default async function printPerformance(
  name,
  signDetached,
  signDetachedVerify,
  signKeyPairFromSeed
) {
  console.log(name);
  let console_log = console.log;
  let console_error = console.error;
  console.log = () => {};
  console.error = () => {};

  let secretKey = await toBytes(fromUrl(identity.secretKey));
  let publicKey = await toBytes(fromUrl(identity.publicKey));
  let longMessage = await createBytesToSign(identity.info);
  let shortMessage = await createBytesToSign({});
  console_log('First run after page load (varies between runs!):');
  {
    let start = performance.now();
    let signature = await signDetached(shortMessage, secretKey);
    let signTime = performance.now() - start;
    start = performance.now();
    await signDetachedVerify(shortMessage, signature, publicKey);
    let verifyTime = performance.now() - start;

    console_log(`sign (short msg):   ${signTime.toFixed(2)} ms`);
    console_log(`verify (short msg): ${verifyTime.toFixed(2)} ms`);
  }
  {
    let start = performance.now();
    let signature = await signDetached(longMessage, secretKey);
    let signTime = performance.now() - start;
    start = performance.now();
    await signDetachedVerify(longMessage, signature, publicKey);
    let verifyTime = performance.now() - start;

    console_log(`sign (long msg):    ${signTime.toFixed(2)} ms`);
    console_log(`verify (long msg):  ${verifyTime.toFixed(2)} ms`);
  }
  console_log('');
  console.log = console_log;
  console.error = console_error;

  if (signKeyPairFromSeed) {
    let seed = (await toBytes(fromUrl(identity.secretKey))).subarray(0, 32);
    let keys = await signKeyPairFromSeed(seed);
    let base64Key = toUrl(await toBase64(keys.publicKey));
    if (base64Key !== identity.publicKey) {
      console.error('keys not equal');
    }
  }

  let n = 50;
  let signLongTimes = Array(n);
  let verifyLongTimes = Array(n);
  let signShortTimes = Array(n);
  let verifyShortTimes = Array(n);
  console.log('Average of 50x after warm-up of 50x:');
  console.log = () => {};
  console.error = () => {};
  let time;
  for (let i = 0; i < 2 * n; i++) {
    {
      let start = performance.now();
      let signature = await signDetached(shortMessage, secretKey);
      time = performance.now() - start;
      if (i >= n) signShortTimes[i - n] = time;
      start = performance.now();
      await signDetachedVerify(shortMessage, signature, publicKey);
      time = performance.now() - start;
      if (i >= n) verifyShortTimes[i - n] = time;
    }

    if (i === 2 * n - 1) {
      console.log = console_log;
      console.error = console_error;
    }

    {
      let start = performance.now();
      let signature = await signDetached(longMessage, secretKey);
      time = performance.now() - start;
      if (i >= n) signLongTimes[i - n] = time;

      // console.log('signature', signature.toString());
      if (
        (await toBase64(signature)) !==
        'v6euinmjEOkHHwArp/nHA18stpd9swkZ6f1/tWz6Y0bqHTgU+S2WE9JPHElpwiMLV7G/xElEpBE8656GgA2gCw=='
      ) {
        console.error('signature not equal');
      }

      start = performance.now();
      let ok = await signDetachedVerify(longMessage, signature, publicKey);
      time = performance.now() - start;
      if (i >= n) verifyLongTimes[i - n] = time;

      if (!ok) {
        console.error('ERROR: verify failed');
        console.log('');
      }
    }
  }

  console.log(`sign (short msg):   ${printMeanStd(signShortTimes)} ms`);
  console.log(`verify (short msg): ${printMeanStd(verifyShortTimes)} ms`);

  console.log(`sign (long msg):    ${printMeanStd(signLongTimes)} ms`);
  console.log(`verify (long msg):  ${printMeanStd(verifyLongTimes)} ms`);
  console.log('');
}

function meanStd(numbers) {
  let sum = 0;
  let sumSquares = 0;
  for (let i of numbers) {
    sum += i;
    sumSquares += i ** 2;
  }
  let n = numbers.length;
  let mean = sum / n;
  let std = Math.sqrt(((sumSquares / n - mean ** 2) * n) / (n - 1));
  return [mean, std];
}

function printMeanStd(numbers) {
  let [mean, std] = meanStd(numbers);
  return `${mean.toFixed(2)} ± ${std.toFixed(2)}`;
}

async function createBytesToSign(data) {
  const certified = JSON.stringify(data);
  const expiration = 1626121765;
  const expirationBytes = new Uint8Array(8);
  let payloadBytes = new TextEncoder().encode(certified);
  for (let i = 0; i < 8; i++) {
    expirationBytes[i] = (expiration >> (8 * i)) & 0xff;
  }
  return concat(expirationBytes, payloadBytes);
}
