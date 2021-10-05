import esbuild from 'esbuild';
import externalPlugin from './esbuild-plugin-external.js';
import subpathImportsPlugin from './esbuild-plugin-subpath-imports.js';

await esbuild.build({
  entryPoints: ['./src/nacl-sign.js'],
  bundle: true,
  outdir: 'dist',
  format: 'esm',
  plugins: [subpathImportsPlugin, externalPlugin],
});

await esbuild.build({
  entryPoints: ['./src/nacl-sign.deno.js'],
  bundle: true,
  outfile: 'mod.js',
  format: 'esm',
  plugins: [subpathImportsPlugin, externalPlugin],
});
