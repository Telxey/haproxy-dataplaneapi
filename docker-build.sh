#!/bin/sh

# Build the standalone DataPlane API container (latest)
echo "Building standalone DataPlane API container (latest)..."
docker build -t telxey/haproxy-dataplaneapi:standalone --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') --build-arg VCS_REF=$(git rev-parse --short HEAD 2>/dev/null || echo 'dev') .

# Build the versioned image
echo "Building standalone DataPlane API container (versioned)..."
docker build -t telxey/haproxy-dataplaneapi:standalone-3.1.4 --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') --build-arg VCS_REF=$(git rev-parse --short HEAD 2>/dev/null || echo 'dev') .

echo "Build completed. You can now push the images to Docker Hub:"
echo "docker push telxey/haproxy-dataplaneapi:standalone"
echo "docker push telxey/haproxy-dataplaneapi:standalone-3.1.4"
