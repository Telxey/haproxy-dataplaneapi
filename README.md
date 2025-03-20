a# HAProxy DataPlane API - Standalone Edition

<p align="right">
  <a href="https://www.buymeacoffee.com/telxey" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-black.png" alt="Buy Me A Coffee" height="41" width="174"></a>
</p>

<p align="center"a
  <img src="https://github.com/user-attachments/assats/f4c27ae9-ca23-4570-b317-754def28c99f" alt="HAProxy Logo" width="300">
</p>a
## Overview

This Docker image provides a standalone implementation of HAProxy DataPlane API, designed for remote management of HAProxy instances. The DataPlane API offers a modern RESTful API to configure HAProxy instances and provides real-time state and metrics information.

**Current Version:** 3.1.4  
**License:** MIT  
**Maintained by:** Telxey  

## Features

- Complete implementation of the HAProxy DataPlane API
- No bundled HAProxy (standalone mode)
- Alpine-based for minimal footprint
- Production-ready with proper security configurations
- Health checks and monitoring endpoints
- Full RESTful API for HAProxy configuration management

## Quickstart

### Option 1: Using pre-built Docker image

```bash
docker run -d --name dataplaneapi \
  -p 5555:5555 \
  -v "$(pwd)/haproxy":/etc/haproxy \
  -e API_USER=admin \
  -e API_PASSWORD=secure_password \
  telxey/haproxy-dataplaneapi:standalone
```

### Option 2: Deploy from source

#### Clone the repository
```bash
git clone https://github.com/Telxey/haproxy-dataplaneapi.git
cd haproxy-dataplaneapi
```

#### Build and run using Docker
```bash
./docker-build.sh
docker run -d --name dataplaneapi \
  -p 5555:5555 \
  -v "$(pwd)/haproxy":/etc/haproxy \
  -e API_USER=admin \
  -e API_PASSWORD=secure_password \
  telxey/haproxy-dataplaneapi:standalone
```

## Configuration Options

### create a docker network support ipv6 if needeed

```docker network create \
  --subnet=10.27.0.0/24 \
  --gateway=10.27.0.254 \
  --ipv6 \
  --subnet=fd4d:0:bebe:cafe::/64 \
  --gateway=fd4d:0:bebe:cafe::254 \
  production
```

### Environment Variables

| Variable | Description | Default Value | Required |
|----------|-------------|---------------|----------|
| `API_USER` | Username for API authentication | `admin` | No |
| `API_PASSWORD` | Password for API authentication | `mypassword` | No |
| `API_PORT` | Port to expose the API | `5555` | No |
| `LOG_LEVEL` | Logging level (debug, info, warning, error) | `info` | No |
| `HAPROXY_SOCKET` | Path to HAProxy stats socket | `/var/run/haproxy.sock` | No |
| `HAPROXY_CONFIG_FILE` | Path to HAProxy configuration file | `/etc/haproxy/haproxy.cfg` | No |
| `RELOAD_DELAY` | Minimum delay between two config reloads (in seconds) | `5` | No |
| `RELOAD_STRATEGY` | Reload strategy (native, service, docker) | `native` | No |
| `TRANSACTION_DIR` | Directory to store transactions | `/etc/haproxy/transactions` | No |
| `BACKUP_DIR` | Directory to store configuration backups | `/etc/haproxy/backups` | No |
| `USERLIST_FILE` | File containing API users | `/etc/haproxy/userlist` | No |
| `TLS_CERTIFICATE` | Path to TLS certificate for HTTPS | `""` | No |
| `TLS_KEY` | Path to TLS key for HTTPS | `""` | No |
| `TLS_CA` | Path to TLS CA for client verification | `""` | No |
| `CLUSTER_ID` | Unique ID for the node in a cluster | `""` | No |
| `CLUSTER_BOOTSTRAP` | Whether to bootstrap a cluster | `false` | No |
| `CLUSTER_PEERS` | Comma-separated list of cluster peer URLs | `""` | No |

### Volumes

| Path | Description |
|------|-------------|
| `/etc/haproxy` | Main configuration directory |
| `/var/log/dataplaneapi` | Log files location |
| `/etc/haproxy/maps` | Directory for HAProxy maps |
| `/etc/haproxy/certs` | Directory for certificates |
| `/etc/haproxy/ssl` | Directory for SSL-related files |
| `/etc/haproxy/lua` | Directory for Lua scripts |
| `/etc/haproxy/spoe` | Directory for SPOE configuration |

### Ports

| Port | Protocol | Description |
|------|----------|-------------|
| 5555 | TCP | DataPlane API HTTP/HTTPS port |

## Usage Examples

### Basic Docker Run Command

```bash
docker run -d --name dataplaneapi \
  -p 5555:5555 \
  -v "$(pwd)/haproxy":/etc/haproxy \
  -e API_USER=admin \
  -e API_PASSWORD=secure_password \
  -e LOG_LEVEL=info \
  telxey/haproxy-dataplaneapi:standalone
```

### Docker Run with TLS Enabled

```bash
docker run -d --name dataplaneapi \
  -p 5555:5555 \
  -v "$(pwd)/haproxy":/etc/haproxy \
  -v "$(pwd)/certs":/etc/haproxy/certs \
  -e API_USER=admin \
  -e API_PASSWORD=secure_password \
  -e TLS_CERTIFICATE=/etc/haproxy/certs/server.pem \
  -e TLS_KEY=/etc/haproxy/certs/server.key \
  telxey/haproxy-dataplaneapi:standalone
```

### Docker Compose Configuration

```yaml
version: '3.8'

services:
  dataplaneapi:
    image: telxey/haproxy-dataplaneapi:standalone
    container_name: dataplaneapi
    restart: unless-stopped
    ports:
      - "5555:5555"
    environment:
      - API_USER=admin
      - API_PASSWORD=secure_password
      - LOG_LEVEL=info
      - HAPROXY_CONFIG_FILE=/etc/haproxy/haproxy.cfg
      - RELOAD_STRATEGY=native
    volumes:
      - ./haproxy:/etc/haproxy
      - ./logs:/var/log/dataplaneapi
    healthcheck:
      test: ["CMD", "curl", "-s", "-f", "-u", "admin:secure_password", "http://localhost:5555/v2/health"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 10s
```

### Advanced Docker Compose Configuration with External HAProxy

```yaml
version: '3.8'

services:
  haproxy:
    image: haproxy:alpine
    container_name: haproxy
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
      - "8404:8404"
    volumes:
      - ./haproxy:/etc/haproxy
      - /var/run/haproxy.sock:/var/run/haproxy.sock

  dataplaneapi:
    image: telxey/haproxy-dataplaneapi:standalone
    container_name: dataplaneapi
    restart: unless-stopped
    ports:
      - "5555:5555"
    environment:
      - API_USER=admin
      - API_PASSWORD=secure_password
      - HAPROXY_SOCKET=/var/run/haproxy.sock
      - HAPROXY_CONFIG_FILE=/etc/haproxy/haproxy.cfg
      - RELOAD_STRATEGY=docker
      - RELOAD_CMD=docker kill -s HUP haproxy
    volumes:
      - ./haproxy:/etc/haproxy
      - /var/run/haproxy.sock:/var/run/haproxy.sock
    depends_on:
      - haproxy
```

## Deployment from Source

### Requirements
- Git
- Docker
- Docker Compose (optional)

### Steps
1. Clone the repository
   ```bash
   git clone https://github.com/Telxey/haproxy-dataplaneapi.git
   cd haproxy-dataplaneapi
   ```

2. Build the Docker image
   ```bash
   ./docker-build.sh
   ```

3. Run using Docker
   ```bash
   docker run -d --name dataplaneapi \
     -p 5555:5555 \
     -v "$(pwd)/haproxy":/etc/haproxy \
     -e API_USER=admin \
     -e API_PASSWORD=secure_password \
     telxey/haproxy-dataplaneapi:standalone
   ```

4. Or deploy using Docker Compose
   ```bash
   docker-compose up -d
   ```

## API Documentation

Once the container is running, you can access the OpenAPI documentation at:
```
http://localhost:5555/v2/docs
```

This provides a complete reference of all available API endpoints with examples and schema information.

## Security Considerations

- Always change the default API credentials (API_USER and API_PASSWORD)
- Consider enabling TLS for production deployments
- Use Docker secrets or environment variables from a secure source for sensitive information
- Restrict network access to the API port (5555) to trusted sources
- Apply the principle of least privilege when mounting volumes

## Performance Tuning

- Adjust the RELOAD_DELAY parameter based on your environment's needs
- For high-traffic environments, consider using the cluster mode
- Monitor resource usage and adjust container limits accordingly

## License

The HAProxy DataPlane API is distributed under the MIT License.
Copyright (c) 2022-2025 HAProxy Technologies LLC.

## Support

For issues, feature requests, or contributions, please visit:
https://github.com/telxey/haproxy-dataplaneapi

For commercial support, contact:
info@telxey.com

<p align="center">
  <a href="https://www.buymeacoffee.com/telxey" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-black.png" alt="Buy Me A Coffee" height="41" width="174"></a>
</p>
