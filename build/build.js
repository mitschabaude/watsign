import esbuild from 'esbuild';
import externalPlugin from './esbuild-plugin-external.js';
import subpathImportsPlugin from './esbuild-plugin-subpath-imports.js';

await esbuild.build({
  entryPoints: ['./src/sign.wat.js'],
  bundle: true,
  outdir: 'dist',
  // outfile: 'dist/watsign.js',
  format: 'esm',
  plugins: [subpathImportsPlugin, externalPlugin],
});

await esbuild.build({
  entryPoints: ['./src/sign.deno.wat.js'],
  bundle: true,
  outfile: 'mod.js',
  format: 'esm',
  plugins: [subpathImportsPlugin, externalPlugin],
});
