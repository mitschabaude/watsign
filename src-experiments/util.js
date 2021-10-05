export {checkArrayTypes, concat};

function checkArrayTypes(...args) {
  if (!args.every(arg => arg instanceof Uint8Array)) {
    throw new TypeError('unexpected type, use Uint8Array');
  }
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
