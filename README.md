# fast-ed25519

This is the signing part of a port of [tweetnacl](http://tweetnacl.cr.yp.to/) to WebAssembly. It is designed to run on the Web as well as in node and deno.

The code is based on and tested against [tweetnacl.js](https://github.com/dchest/tweetnacl-js).

**Documentation is coming soon**

## Testing

```sh
# before you do anything else
yarn

# test and compare with tweetnacl.js
node test/test.js

# test and watch for changes
npx chrodemon --wasm-wrap test/test-nacl-modified.js
```
