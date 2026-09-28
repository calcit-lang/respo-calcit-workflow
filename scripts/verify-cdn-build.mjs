import { readFileSync, existsSync, statSync } from 'node:fs';
import { join } from 'node:path';

const base = process.env.VITE_BASE_URL;
if (!base || !base.endsWith('/')) {
  throw new Error('VITE_BASE_URL must be an absolute URL ending in /');
}

const html = readFileSync('dist/index.html', 'utf8');
const assetUrls = [...html.matchAll(/(?:src|href)="(https:\/\/cos-sh\.tiye\.me\/[^\"]+)"/g)]
  .map((match) => match[1]);
if (!assetUrls.some((url) => url.endsWith('.js'))) {
  throw new Error('Built HTML must load JavaScript from COS');
}

for (const url of assetUrls) {
  if (!url.startsWith(base)) {
    throw new Error(`Unexpected CDN asset URL: ${url}`);
  }
  const relativePath = decodeURIComponent(url.slice(base.length));
  if (!relativePath.startsWith('assets/') || !existsSync(join('dist', relativePath))) {
    throw new Error(`Missing local asset for ${url}`);
  }
}

console.log(`Verified ${assetUrls.length} CDN assets under ${base}`);

if (process.argv.includes('--remote')) {
  for (const url of assetUrls) {
    const localPath = join('dist', decodeURIComponent(url.slice(base.length)));
    let verified = false;
    for (let attempt = 0; attempt < 6; attempt += 1) {
      try {
        const response = await fetch(url, { cache: 'no-store' });
        if (response.ok && (await response.arrayBuffer()).byteLength === statSync(localPath).size) {
          verified = true;
          break;
        }
      } catch {
        // The CDN may not see a newly uploaded object immediately.
      }
      await new Promise((resolve) => setTimeout(resolve, 2000));
    }
    if (!verified) {
      throw new Error(`CDN asset is unavailable or has the wrong size: ${url}`);
    }
  }
  console.log('Verified uploaded assets through the public CDN');
}
