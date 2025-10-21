

/** @type {import('next').NextConfig} */
const nextConfig = {
  async headers() {
    return [
      {
        source: '/:path*',
        headers: [
          {
            key: 'Content-Security-Policy',
            value: [
 "default-src 'self'",
              "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com https://checkout.stripe.com",
              "script-src 'self' 'unsafe-inline' 'unsafe-eval' https://js.stripe.com https://checkout.stripe.com",
              "frame-src https://js.stripe.com https://checkout.stripe.com https://hooks.stripe.com",
              "connect-src 'self' https://mp-club-production.up.railway.app https://api.stripe.com https://checkout.stripe.com https://m.stripe.com",
              "img-src 'self' data: https: https://*.stripe.com",
              "font-src 'self' https://fonts.gstatic.com data:",
            ].join('; '),
          },
        ],
      },
    ];
  },
  eslint: {
    ignoreDuringBuilds: true,
  },
  typescript: {
    ignoreBuildErrors: true,
  },
};

module.exports = nextConfig;
