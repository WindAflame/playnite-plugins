// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// https://astro.build/config
export default defineConfig({
	// Builds straight into the repo-root dist/, alongside the packed plugins,
	// instead of the default docs/dist/ - dist/ is the single build output
	// location for every project in this monorepo.
	outDir: '../dist/docs',
	site: 'https://WindAflame.github.io',
	base: '/playnite-retroarch-steam-romm-kit',
	integrations: [
		starlight({
			title: 'Playnite Plugins',
			description:
				'User guide and download links for the RetroArch (Steam) and RomM save-sync Playnite extensions.',
			social: [
				{
					icon: 'github',
					label: 'GitHub',
					href: 'https://github.com/WindAflame/playnite-retroarch-steam-romm-kit',
				},
			],
			sidebar: [
				{
					label: 'Guides',
					items: [{ label: 'Getting Started', slug: 'guides/getting-started' }],
				},
				{
					label: 'Plugins',
					items: [
						{ label: 'RetroArch (Steam)', slug: 'plugins/retroarch-steam' },
						{ label: 'RomM Save Sync', slug: 'plugins/romm-save-sync' },
					],
				},
			],
		}),
	],
});
