/**
 * Generate docs/brand/og-preview.png (1200×630) for Open Graph / Twitter cards.
 * Run: node scripts/generate-og-preview.mjs
 */
import sharp from 'sharp';
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const brand = join(root, 'docs/brand');
const logoSvg = readFileSync(join(brand, 'redhat-logo-on-dark.svg'));

const W = 1200;
const H = 630;

const logoPng = await sharp(logoSvg, { density: 300 })
  .resize({ width: 420, fit: 'inside' })
  .png()
  .toBuffer();

const logoMeta = await sharp(logoPng).metadata();
const logoW = logoMeta.width ?? 420;
const logoH = logoMeta.height ?? 112;
const logoLeft = Math.round((W - logoW) / 2);
const logoTop = 150;

const svgOverlay = Buffer.from(`
<svg width="${W}" height="${H}" xmlns="http://www.w3.org/2000/svg">
  <rect width="${W}" height="${H}" fill="#151515"/>
  <rect x="0" y="0" width="${W}" height="8" fill="#EE0000"/>
  <text x="600" y="380" text-anchor="middle" font-family="Red Hat Text, Overpass, Helvetica, Arial, sans-serif"
        font-size="40" font-weight="700" fill="#FFFFFF">Red Hat Lightwell Network</text>
  <text x="600" y="440" text-anchor="middle" font-family="Red Hat Text, Overpass, Helvetica, Arial, sans-serif"
        font-size="26" font-weight="400" fill="#C7C7C7">demo-lightwell · Secure Java deps on OpenShift Dev Spaces</text>
  <text x="600" y="520" text-anchor="middle" font-family="Red Hat Text, Overpass, Helvetica, Arial, sans-serif"
        font-size="20" font-weight="400" fill="#8A8D90">Lightwell · Nexus · Dev Spaces · Pipelines</text>
  <rect x="0" y="${H - 8}" width="${W}" height="8" fill="#EE0000"/>
</svg>
`);

await sharp(svgOverlay)
  .composite([{ input: logoPng, left: logoLeft, top: logoTop }])
  .png()
  .toFile(join(brand, 'og-preview.png'));

console.log('Wrote docs/brand/og-preview.png (1200×630)');
