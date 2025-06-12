# Simple Next.js build for development/testing
FROM node:18-alpine

# Install dependencies
RUN apk add --no-cache libc6-compat curl

# Set working directory
WORKDIR /app

# Set environment variables
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

# Copy package files
COPY package.json package-lock.json* ./

# Clean install dependencies
RUN npm ci --only=production && npm cache clean --force

# Copy source code (excluding node_modules)
COPY . .
RUN rm -rf node_modules

# Reinstall all dependencies (including dev dependencies for build)
RUN npm ci

# Set build-time environment variables
ARG NEXT_PUBLIC_API_URL
ENV NEXT_PUBLIC_API_URL=${NEXT_PUBLIC_API_URL:-http://localhost:5050}
ENV API_BASE_URL=${NEXT_PUBLIC_API_URL:-http://localhost:5050}

# Build the application
RUN npm run build

# Remove dev dependencies after build
RUN npm prune --production

# Create non-root user
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

# Change ownership
RUN chown -R nextjs:nodejs /app

USER nextjs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/ || exit 1

# Start the application
CMD ["npm", "start"]
