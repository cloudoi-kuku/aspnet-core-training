/** @type {import('next').NextConfig} */
const nextConfig = {
  // Enable React strict mode for better development experience
  reactStrictMode: true,
  
  // Enable SWC minification for better performance
  swcMinify: true,
  
  // Environment variables
  env: {
    API_BASE_URL: process.env.API_BASE_URL || 'http://localhost:5050',
    NEXT_PUBLIC_API_URL: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:5050',
  },
  
  // API routes configuration
  // Disabled rewrites - using direct API calls from client
  // async rewrites() {
  //   return [
  //     {
  //       source: '/api/:path*',
  //       destination: `${process.env.API_BASE_URL || 'http://localhost:5050'}/api/:path*`,
  //     },
  //   ];
  // },
  
  // Image optimization
  images: {
    domains: ['localhost', 'ecommerce-backend'],
    formats: ['image/webp', 'image/avif'],
  },
  
  // Output configuration for Docker
  // output: 'standalone', // Disabled to use standard Next.js server
  
  
  // Headers for security
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          {
            key: 'X-Frame-Options',
            value: 'DENY',
          },
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff',
          },
          {
            key: 'Referrer-Policy',
            value: 'strict-origin-when-cross-origin',
          },
        ],
      },
    ];
  },
  
  // Webpack configuration
  webpack: (config, { buildId, dev, isServer, defaultLoaders, webpack }) => {
    // Custom webpack configuration if needed
    return config;
  },
  
  // TypeScript configuration
  typescript: {
    // Dangerously allow production builds to successfully complete even if
    // your project has type errors.
    ignoreBuildErrors: false,
  },
  
  // ESLint configuration
  eslint: {
    // Warning: This allows production builds to successfully complete even if
    // your project has ESLint errors.
    ignoreDuringBuilds: false,
  },
};

module.exports = nextConfig;
