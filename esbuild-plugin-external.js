export {makeAllPackagesExternalPlugin as default};

let makeAllPackagesExternalPlugin = {
  name: 'make-all-packages-external',
  setup(build) {
    let filter = /^[^./]|^\.[^./]|^\.\.[^/]|#/; // Must not start with "/" or "./" or "../" or "#"
    build.onResolve({filter}, ({path}) => ({path, external: true}));
  },
};
