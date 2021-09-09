export {concat};

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

// UNUSED

function Uint8ToInt64Array(array) {
  let length = array.length;
  let buffer = new ArrayBuffer(length * 8);
  let view = new DataView(buffer);
  for (let i = 0; i < length; i++) {
    view.setInt8(i * 8, array[i], true);
  }
  return buffer;
}
function Int64Array(array) {
  let length = array.length;
  let buffer = new ArrayBuffer(length * 8);
  let view = new DataView(buffer);
  for (let i = 0; i < length; i++) {
    view.setBigInt64(i * 8, BigInt(array[i]), true);
  }
  return buffer;
}
