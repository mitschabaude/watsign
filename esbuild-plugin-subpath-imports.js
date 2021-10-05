/* this is the beginning of a potential esbuild plugin that resolves internal "#*" imports
  using the "imports" field in package.json, like node
  see https://nodejs.org/api/packages.html#packages_subpath_imports
  
  known TODOs:
  -) wildcard patterns
  -) resolve node modules
*/
import fs from 'node:fs';
import path from 'node:path';
const {readdir, readFile} = fs.promises;

export {subpathImportsPlugin as default};

let subpathImportsPlugin = {
  name: 'subpath-imports',
  async setup(build) {
    let platform = build.initialOptions.platform ?? 'browser';
    let conditions = [
      ...(build.initialOptions.conditions ?? []),
      platform,
      'default',
    ];
    // console.log('conditions', conditions);
    let [packageDir, packageJson] = await findPackageDirAndJson();
    let subpathImports = packageJson?.imports;

    build.onResolve({filter: /^#/}, args => {
      let specificConditions = conditions.concat(
        {
          'import-statement': ['import'],
          'require-call': ['require'],
          'dynamic-import': ['import'],
          'require-resolve': ['require'],
        }[args.kind] ?? []
      );
      let importConditions = subpathImports[args.path];
      let relPath;
      switch (typeof importConditions) {
        case 'string':
          relPath = importConditions;
          break;
        case 'object': {
          for (let cond in importConditions) {
            // "default" is checked last because that's the intended meaning, to avoid a gotcha when putting "default" first
            if (cond === 'default') continue;
            let activeCond = specificConditions.find(s => cond === s);
            if (activeCond) {
              relPath = importConditions[activeCond];
              break;
            }
          }
          if (!relPath) {
            if (importConditions.default) relPath = importConditions.default;
            else return;
          }
          break;
        }
        default:
          // no subpath import found => do nothing
          return;
      }
      return {path: path.resolve(packageDir, relPath)};
    });
  },
};

async function findPackageDirAndJson() {
  for (let d = path.resolve('.'); d !== '/'; d = path.resolve(d, '..')) {
    const packageJson = await getPackageJson(d);
    if (packageJson) return [d, packageJson];
  }
}

async function getPackageJson(dir) {
  const files = await readdir(dir);
  if (!files.includes('package.json')) return null;
  return await readJson(dir, 'package.json');
}

async function readJson(...filePaths) {
  return JSON.parse(
    await readFile(path.resolve(...filePaths), {encoding: 'utf-8'})
  );
}
