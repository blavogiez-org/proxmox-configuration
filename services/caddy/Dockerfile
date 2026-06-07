# caddy avec plugin pour rate limit
ARG CADDY_VERSION=2

FROM caddy:${CADDY_VERSION}-builder-alpine AS builder

RUN xcaddy build --with github.com/mholt/caddy-ratelimit

FROM caddy:${CADDY_VERSION}-alpine

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 CMD caddy validate --config /etc/caddy/Caddyfile

USER caddy
