import identity from './identity.json';
import {toBytes} from 'fast-base64';
import {fromUrl} from 'fast-base64/url';

export default async function printPerformance(name, sign, verify, createKeys) {
  console.log(name);

  let n = 50;
  let signLongTimes = Array(n);
  let verifyLongTimes = Array(n);
  let signShortTimes = Array(n);
  let verifyShortTimes = Array(n);

  if (createKeys) {
    let seed = (await toBytes(fromUrl(identity.secretKey))).subarray(0, 32);
    let keys = await createKeys(seed);
    if (keys.publicKey !== identity.publicKey) {
      console.error('keys not equal');
    }
  }

  let console_log = console.log;
  let console_error = console.error;
  console.log = () => {};
  console.error = () => {};
  for (let i = 0; i < 2 * n; i++) {
    {
      let data = {};
      let start = performance.now();
      let signed = await sign(identity, data);
      if (i >= n) signShortTimes[i - n] = performance.now() - start;
      start = performance.now();
      await verify(signed, identity.publicKey);
      if (i >= n) verifyShortTimes[i - n] = performance.now() - start;
    }

    if (i === n - 1) {
      console.log = console_log;
      console.error = console_error;
    }

    {
      let data = identity.info;
      let start = performance.now();
      let signed = await sign(identity, data);
      if (i >= n) signLongTimes[i - n] = performance.now() - start;

      let sig = signed.signature?.payload ?? signed.Signatures[0].Payload;
      // console.log('signature', sig);
      if (
        sig !==
        'v6euinmjEOkHHwArp/nHA18stpd9swkZ6f1/tWz6Y0bqHTgU+S2WE9JPHElpwiMLV7G/xElEpBE8656GgA2gCw=='
      ) {
        console.error('signature not equal');
      }

      start = performance.now();
      let result = await verify(signed, identity.publicKey);
      if (i >= n) verifyLongTimes[i - n] = performance.now() - start;

      if (result?.name !== data?.name) {
        console.error('ERROR: verify failed');
        console.log('');
        // return;
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
