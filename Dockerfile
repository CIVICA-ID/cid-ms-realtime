# ===========================================
# CID-MS-REALTIME - DOCKERFILE
# Multi-stage build for NestJS application
# ===========================================

# ---------------------------------------------
# Stage 1: Dependencies
# ---------------------------------------------
FROM node:20-alpine AS dependencies

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies (including dev for building)
RUN npm ci

# ---------------------------------------------
# Stage 2: Build
# ---------------------------------------------
FROM node:20-alpine AS build

WORKDIR /app

# Copy dependencies from previous stage
COPY --from=dependencies /app/node_modules ./node_modules
COPY . .

# Build the application
RUN npm run build

# Prune dev dependencies
RUN npm prune --production

# ---------------------------------------------
# Stage 3: Development
# ---------------------------------------------
FROM node:20-alpine AS development

WORKDIR /app

# Install curl for health checks
RUN apk add --no-cache curl wget

# Copy package files and install all dependencies
COPY package*.json ./
RUN npm ci

# Copy source code
COPY . .

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nestjs -u 1001

# Set ownership
RUN chown -R nestjs:nodejs /app

USER nestjs

# Expose port
EXPOSE ${PORT:-3004}

# Start in development mode
CMD ["npm", "run", "start:dev"]

# ---------------------------------------------
# Stage 4: Production
# ---------------------------------------------
FROM node:20-alpine AS production

WORKDIR /app

# Install wget for health checks
RUN apk add --no-cache wget

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nestjs -u 1001

# Copy only production dependencies and built files
COPY --from=build --chown=nestjs:nodejs /app/node_modules ./node_modules
COPY --from=build --chown=nestjs:nodejs /app/dist ./dist
COPY --from=build --chown=nestjs:nodejs /app/package*.json ./

# Switch to non-root user
USER nestjs

# Expose port
EXPOSE ${PORT:-3004}

# Set environment
ENV NODE_ENV=production

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:${PORT:-3004}/health || exit 1

# Start the application
CMD ["node", "dist/main"]
