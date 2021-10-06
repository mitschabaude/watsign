export async function createBytesToSign(data) {
  const certified = JSON.stringify(data);
  const expiration = 1626121765;
  const expirationBytes = new Uint8Array(8);
  let payloadBytes = new TextEncoder().encode(certified);
  // this code is actually wrong... n >> k === n >> (k % 32) for k >= 32, so n >> 32 is just n
  // https://262.ecma-international.org/6.0/#sec-left-shift-operator
  for (let i = 0; i < 8; i++) {
    expirationBytes[i] = (expiration >> (8 * i)) & 0xff;
  }
  // this is correct:
  // let view = new DataView(expirationBytes.buffer);
  // view.setBigInt64(0, BigInt(expiration), true);
  return concat(expirationBytes, payloadBytes);
}

function concat(...arrays) {
  if (!arrays.length) return new Uint8Array();
  let totalLength = arrays.reduce((acc, value) => acc + value.length, 0);
  let result = new Uint8Array(totalLength);
  let length = 0;
  for (let array of arrays) {
    result.set(array, length);
    length += array.length;
  }
  return result;
}
