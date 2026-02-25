import { build } from 'esbuild';
import { globSync } from 'node:fs';

const entryPoints = globSync('src/lambdas/**/index.mts');

await build({
  entryPoints,
  bundle: true,
  platform: 'node',
  target: 'es2022',
  format: 'cjs',
  sourcemap: true,
  minify: false,
  outdir: 'dist',
  outbase: 'src',
  // Reads paths alias from tsconfig: src/* -> src/*
  tsconfig: 'tsconfig.json',
  external: [
    // AWS SDK - available in Lambda runtime or resolved from node_modules
    'aws-sdk',
    '@aws-sdk/*',
    // Native/optional dependencies not needed in Lambda
    'pg-native',
    'better-sqlite3',
    'mysql2',
    'tedious',
    'pg-query-stream',
    'oracledb',
    'mysql',
    'sqlite3',
  ],
});

console.log(`Built ${entryPoints.length} lambda entry points to dist/`);
