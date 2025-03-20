#!/bin/sh
set -e

# Print version information
DATAPLANEAPI_VERSION=$(dataplaneapi --version | grep -oP 'v\d+\.\d+\.\d+')
echo "Starting HAProxy DataPlane API ${DATAPLANEAPI_VERSION}"
echo "Container initialization..."

# Default paths (maintain consistency but without actually using HAProxy)
DEFAULT_CONFIG_FILE=${CONFIG_FILE:-/etc/haproxy/haproxy.cfg}
DEFAULT_SOCKET_PATH=${SOCKET_PATH:-/var/run/haproxy/haproxy.sock}
DEFAULT_PID_FILE=${PID_FILE:-/var/run/haproxy/haproxy.pid}

# Process templates if they exist
if [ -f "/etc/haproxy/dataplaneapi.yml.template" ]; then
    echo "Processing dataplaneapi.yml template..."
    envsubst < /etc/haproxy/dataplaneapi.yml.template > /etc/haproxy/dataplaneapi.yml
    echo "Template processing complete."
fi

# Create default configuration if it doesn't exist
if [ ! -f "/etc/haproxy/dataplaneapi.yml" ]; then
    echo "No configuration file found, creating default configuration..."
    
    # Set default values for required parameters
    CONFIG_FILE=${CONFIG_FILE:-/etc/haproxy/haproxy.cfg}
    HAPROXY_BIN=${HAPROXY_BIN:-/usr/sbin/haproxy}
    RELOAD_DELAY=${RELOAD_DELAY:-5}
    # Since we're not running HAProxy in the container, these commands are placeholders
    # They would need to interact with an external HAProxy instance via socket or API
    RELOAD_CMD=${RELOAD_CMD:-"echo 'Reload would be triggered here'"}
    RESTART_CMD=${RESTART_CMD:-"echo 'Restart would be triggered here'"}
    API_USER=${API_USER:-admin}
    API_PASSWORD=${API_PASSWORD:-mypassword}
    API_HOST=${API_HOST:-*******}
    API_PORT=${API_PORT:-5555}
    LOG_LEVEL=${LOG_LEVEL:-info}
    MAPS_DIR=${MAPS_DIR:-/etc/haproxy/maps}
    SSL_CERTS_DIR=${SSL_CERTS_DIR:-/etc/haproxy/ssl}
    
    # Create configuration file
    cat > /etc/haproxy/dataplaneapi.yml << EOF2
config_file: ${CONFIG_FILE}
haproxy_binary: ${HAPROXY_BIN}
reload_delay: ${RELOAD_DELAY}
reload_cmd: "${RELOAD_CMD}"
restart_cmd: "${RESTART_CMD}"
master_runtime: ${DEFAULT_SOCKET_PATH}

resources:
  maps_dir: ${MAPS_DIR}
  ssl_certs_dir: ${SSL_CERTS_DIR}

api:
  host: ${API_HOST}
  port: ${API_PORT}
  user: ${API_USER}
  password: ${API_PASSWORD}

log:
  level: ${LOG_LEVEL}
EOF2
    echo "Default configuration created."
fi

# Function to handle graceful shutdown
graceful_shutdown() {
    echo "Received shutdown signal, exiting gracefully..."
    exit 0
}

# Set up signal handling
trap graceful_shutdown SIGTERM SIGINT

# Check if user passed direct arguments to DataPlane API
if [ "$1" = "--config-file" ] || [ "$1" = "-c" ] || [ "$1" = "--port" ] || [ "$1" = "-p" ]; then
    echo "Starting DataPlane API with provided arguments..."
    exec dataplaneapi "$@"
else
    # Start with default arguments
    echo "Starting DataPlane API with default configuration..."
    exec dataplaneapi --config-file /etc/haproxy/dataplaneapi.yml
fi
