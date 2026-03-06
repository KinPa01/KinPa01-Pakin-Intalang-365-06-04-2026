# Stage 1: Build
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
# Install ALL dependencies (including devDependencies for building)
RUN npm ci
COPY . .
# Generate Prisma Client
RUN DATABASE_URL="postgresql://dummy:dummy@localhost:5432/mydb" npx prisma generate
# Build TypeScript
RUN npm run build

# Stage 2: Production
FROM node:20-alpine
WORKDIR /app

ENV NODE_ENV=production

# Install OpenSSL and compatibility libraries for Prisma
RUN apk add --no-cache openssl libc6-compat

# Create logs directory
RUN mkdir -p /app/logs && chown -R node:node /app

USER node

COPY package*.json ./
# Install only production dependencies
RUN npm ci --only=production

# Copy built application from builder stage
COPY --from=builder --chown=node:node /app/dist ./dist
# logs directory
# Copy prisma schema if needed for runtime reference
COPY --from=builder --chown=node:node /app/prisma ./prisma
# Copy generated Prisma Client
COPY --from=builder --chown=node:node /app/node_modules/.prisma ./node_modules/.prisma

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:3000/api/health || exit 1

EXPOSE 3000

# ตัวอย่างถ้าไฟล์อยู่ใน dist/src/
CMD ["node", "dist/src/server.js"]
