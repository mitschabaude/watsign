# fast-ed25519

This is the signing part of a port of [tweetnacl](http://tweetnacl.cr.yp.to/) to WebAssembly. It is designed to run on the Web as well as in node and deno.

The code is based on and tested against [tweetnacl.js](https://github.com/dchest/tweetnacl-js).

**Documentation is coming soon**

## Performance

Performance compared to `tweetnacl.js` on my laptop in Chromium 92 (via puppeteer). We are 3-5x faster in the warmed-up regime and 5-50x faster on cold start after page load.

- **Our version**

```sh
First run after page load (varies between runs!):
sign (short msg):   3.40 ms
verify (short msg): 2.09 ms
sign (long msg):    1.71 ms
verify (long msg):  2.06 ms

Average of 50x after warm-up of 50x:
sign (short msg):   1.12 ± 0.14 ms
verify (short msg): 1.57 ± 0.23 ms
sign (long msg):    1.48 ± 0.13 ms
verify (long msg):  1.77 ± 0.13 ms
```

- **tweetnacl.js**

```sh
First run after page load (varies between runs!):
sign (short msg):   29.58 ms
verify (short msg): 15.70 ms
sign (long msg):    91.31 ms
verify (long msg):  22.83 ms

Average of 50x after warm-up of 50x:
sign (short msg):   4.13 ± 0.37 ms
verify (short msg): 8.25 ± 0.42 ms
sign (long msg):    8.65 ± 0.42 ms
verify (long msg):  10.87 ± 0.48 ms
```

## Testing

```sh
# before you do anything else
yarn

# build wasm (TODO: this should happen automatically again)
npx watever ./src/wat/sign.wat

# test and compare with tweetnacl.js
node test/test.js

# test and watch for changes (TODO watching currently doesn't work)
npx chrodemon test/test-nacl-modified.js
```
