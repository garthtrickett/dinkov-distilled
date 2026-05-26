/** @type {import('next').NextConfig} */
const nextConfig = {
  typescript: {
    ignoreBuildErrors: true,
  },
  eslint: {
    ignoreDuringBuilds: true,
  },
  async rewrites() {
    return {
      beforeFiles: [
        {
          // Match any slug containing no dots or slashes, followed exactly by '.md'
          source: '/:slug([^./]+).md',
          destination: '/:slug',
        },
        {
          // Match any folder-prefixed slug containing no dots or slashes, followed exactly by '.md'
          source: '/content/:slug([^./]+).md',
          destination: '/:slug',
        },
      ],
    }
  },
}

module.exports = nextConfig
