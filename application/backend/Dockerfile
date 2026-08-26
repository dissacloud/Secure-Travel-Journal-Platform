FROM node:22-alpine AS dependencies

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm ci --omit=dev && npm cache clean --force

FROM node:22-alpine AS runtime

ENV NODE_ENV=production

WORKDIR /app

RUN apk upgrade --no-cache \
    && addgroup -S appgroup \
    && adduser -S appuser -G appgroup \
    && rm -rf /usr/local/lib/node_modules/npm \
    && rm -f /usr/local/bin/npm /usr/local/bin/npx

COPY --from=dependencies --chown=appuser:appgroup /app/node_modules ./node_modules

COPY --chown=appuser:appgroup package.json ./package.json

COPY --chown=appuser:appgroup src ./src

USER appuser

EXPOSE 5000

CMD ["node", "src/server.js"]