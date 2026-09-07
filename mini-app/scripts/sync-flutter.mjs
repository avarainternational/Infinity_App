import { mkdir, copyFile } from 'node:fs/promises';
const destination = new URL('../../assets/mini_apps/reward_shop/', import.meta.url);
await mkdir(destination, { recursive: true });
await copyFile(new URL('../dist/index.html', import.meta.url), new URL('index.html', destination));
console.log('Bundled Reward Shop into Flutter assets. Rebuild Flutter to pick up changes.');
