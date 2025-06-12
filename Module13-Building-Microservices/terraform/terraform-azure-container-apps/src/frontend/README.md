# E-Commerce Frontend

A modern, responsive e-commerce frontend built with Next.js, TypeScript, and Tailwind CSS.

## Features

- 🚀 Server-side rendering with Next.js
- 💎 TypeScript for type safety
- 🎨 Tailwind CSS for modern, responsive design
- 🛒 Shopping cart functionality
- 🔐 JWT authentication
- 📱 Mobile-responsive design
- 🎯 Product search and filtering
- 💳 Secure checkout process

## Prerequisites

- Node.js 18+ 
- npm 9+
- Backend API running on http://localhost:5000

## Installation

1. Install dependencies:
```bash
npm install
```

2. Create environment file:
```bash
cp .env.local.example .env.local
```

3. Update `.env.local` with your configuration:
```
NEXT_PUBLIC_API_URL=http://localhost:5000
```

## Development

Run the development server:

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) to view the application.

## Build

Build for production:

```bash
npm run build
```

## Production

Run the production server:

```bash
npm start
```

## Docker

Build and run with Docker:

```bash
docker build -t ecommerce-frontend .
docker run -p 3000:3000 ecommerce-frontend
```

## Project Structure

```
src/frontend/
├── components/       # Reusable React components
├── lib/             # Utilities and API client
│   └── api/         # API service layer
├── pages/           # Next.js pages
├── public/          # Static assets
├── styles/          # Global styles
├── types/           # TypeScript type definitions
└── utils/           # Helper functions
```

## Key Technologies

- **Next.js 14** - React framework with SSR/SSG
- **TypeScript** - Type safety
- **Tailwind CSS** - Utility-first CSS framework
- **Axios** - HTTP client
- **React Hook Form** - Form handling
- **React Hot Toast** - Toast notifications
- **Heroicons** - SVG icons

## Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm start` - Start production server
- `npm run lint` - Run ESLint
- `npm run type-check` - Run TypeScript compiler check
- `npm test` - Run tests

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `NEXT_PUBLIC_API_URL` | Backend API URL | http://localhost:5000 |
| `NEXT_PUBLIC_SITE_NAME` | Site name | E-Commerce Platform |
| `NEXT_PUBLIC_SITE_URL` | Frontend URL | http://localhost:3000 |

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request