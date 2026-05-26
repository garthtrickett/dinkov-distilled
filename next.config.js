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
          // Intercept standard root markdown paths (e.g. /some-chapter.md)
          source: '/:slug.md',
          destination: '/:slug',
        },
        {
          // Intercept folder-prefixed markdown paths (e.g. /content/some-chapter.md)
          source: '/content/:slug.md',
          destination: '/:slug',
        },
      ],
    }
  },
}

module.exports = nextConfig
