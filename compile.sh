#!/bin/bash

set -e

# Cleanup output directory (if exists)
rm -rf output

# Create output directory
mkdir -p output

# Update submodules
git submodule update --init --recursive

# Remove existing docker image
docker rmi unitedmanufacturinghub/ipxe:latest

# Build new docker image with cache busting
docker build -t unitedmanufacturinghub/ipxe:latest --build-arg CACHEBUST=$(date +%s) .

# Run the docker container and log the output
docker run --rm -v "$(pwd)/output:/output" -it unitedmanufacturinghub/ipxe:latest | tee output/ipxe.log
