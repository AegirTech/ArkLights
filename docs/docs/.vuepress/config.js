import { defaultTheme } from '@vuepress/theme-default'
import { defineUserConfig } from 'vuepress/cli'
import { viteBundler } from '@vuepress/bundler-vite'
import { searchPlugin } from '@vuepress/plugin-search'

export default defineUserConfig({
  lang: 'zh-CN',
  title: '明日方舟速通',
  description: '高效的明日方舟全托管APP',
  repo: 'AegirTech/ArkLights',

  theme: defaultTheme({
    sidebarDepth: 2,
    navbar: [{ text: '必读', link: '/guide.md' }, { text: '肉鸽', link: '/rouge.md' }, { text: '多开/云控', link: '/multi.md' }, { text: '其他问题', link: '/other.md' },
    { text: '开发', link: '/development.md' }],
  }),
  markdown: {
    headers: {
      level: [2, 3, 4, 5],
    },
  },
  bundler: viteBundler(),
  plugins: [
    searchPlugin({
      // 配置项
    }),
  ],
})
