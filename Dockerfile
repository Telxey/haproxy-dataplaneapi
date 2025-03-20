FROM alpine:3.21 AS builder

# Version as build argument for easier updates
ARG DATAPLANEAPI_VERSION=v3.1.4

# Download DataPlane API
RUN apk add --no-cache wget && \
    wget "https://github.com/haproxytech/dataplaneapi/releases/download/${DATAPLANEAPI_VERSION}/dataplaneapi_${DATAPLANEAPI_VERSION#v}_linux_amd64.apk" -O /tmp/dataplaneapi.apk

FROM alpine:3.21

# Version info for labels
ARG DATAPLANEAPI_VERSION=v3.1.4
ARG BUILD_DATE
ARG VCS_REF

# Metadata labels
LABEL maintainer="Telxey <info@telxey.com>" \
      description="Standalone HAProxy DataPlane API for managing HAProxy configurations" \
      version="${DATAPLANEAPI_VERSION}" \
      org.opencontainers.image.title="Standalone HAProxy DataPlane API" \
      org.opencontainers.image.description="Enterprise-ready standalone HAProxy DataPlane API container" \
      org.opencontainers.image.version="${DATAPLANEAPI_VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.source="https://github.com/haproxytech/dataplaneapi" \
      org.opencontainers.image.url="https://github.com/telxey/haproxy-dataplaneapi" \
      org.opencontainers.image.documentation="https://www.haproxy.com/documentation/dataplaneapi/" \
      org.opencontainers.image.licenses="MIT"

# Install dependencies and set up user (without haproxy)
RUN apk add --no-cache \
    ca-certificates \
    curl \
    jq \
    socat \
    tzdata && \
    addgroup -S haproxy && \
    adduser -S -G haproxy haproxy

# Copy and install DataPlane API from builder stage
COPY --from=builder /tmp/dataplaneapi.apk /tmp/
RUN apk add --allow-untrusted /tmp/dataplaneapi.apk && \
    rm /tmp/dataplaneapi.apk

# Create necessary directories with consistent paths
RUN mkdir -p /etc/haproxy/maps \
            /etc/haproxy/certs \
            /etc/haproxy/ssl \
            /etc/haproxy/lua \
            /etc/haproxy/spoe \
            /var/run/haproxy \
            /var/log/dataplaneapi && \
    chown -R haproxy:haproxy /etc/haproxy \
                            /var/run/haproxy \
                            /var/log/dataplaneapi

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Define volumes for persistent data
VOLUME ["/etc/haproxy", "/var/log/dataplaneapi"]

# Set working directory
WORKDIR /etc/haproxy

# Add health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD curl -s -f -u "${API_USER:-admin}:${API_PASSWORD:-mypassword}" "http://localhost:${API_PORT:-5555}/v2/health" || exit 1

# Expose API port
EXPOSE 5555

# Switch to non-root user for better security
USER haproxy

# Set entrypoint and default command
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["--config-file", "/etc/haproxy/dataplaneapi.yml"]
