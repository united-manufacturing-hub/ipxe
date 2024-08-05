#!/usr/bin/env bash
cd /src || exit 1
set -e

# Remove old build files
rm -rf bin-*

# Variables
EMBED="embed.ipxe"

cert_urls=(
  "https://letsencrypt.org/certs/isrgrootx1.pem"
  "https://letsencrypt.org/certs/isrg-root-x2.pem"
  "https://letsencrypt.org/certs/2024/e5.pem"
  "https://letsencrypt.org/certs/2024/e6.pem"
  "https://letsencrypt.org/certs/2024/e7.pem"
  "https://letsencrypt.org/certs/2024/e8.pem"
  "https://letsencrypt.org/certs/2024/e9.pem"
  "https://letsencrypt.org/certs/2024/r10.pem"
  "https://letsencrypt.org/certs/2024/r11.pem"
  "https://letsencrypt.org/certs/2024/r12.pem"
  "https://letsencrypt.org/certs/2024/r13.pem"
  "https://letsencrypt.org/certs/2024/r14.pem"
)

# Download certificates
for url in "${cert_urls[@]}"; do
  echo "Downloading $(basename $url)..."
  wget $url -O "config/$(basename $url)"
done

echo "All certificates have been downloaded."

# Build CERT_TRUST array, by reading config folder (all .pem files)
CERT_TRUST=()
for file in config/*.pem; do
    CERT_TRUST+=("$file")
done

# Convert array to comma-separated string
CERT_TRUST_STR=$(IFS=, ; echo "${CERT_TRUST[*]}")

# Build targets
declare -A targets=(
    ["x86_64-efi"]="bin-x86_64-efi/ipxe.iso bin-x86_64-efi/ipxe.usb"
    ["x86_64-bios"]="bin-x86_64-pcbios/ipxe.iso bin-x86_64-pcbios/ipxe.usb bin-x86_64-pcbios/ipxe.vhd"
    ["arm64-efi"]="bin-arm64-efi/ipxe.iso bin-arm64-efi/ipxe.usb"
)

# Make builds
for target in "${!targets[@]}"; do
    echo "Building $target"
    for output in ${targets[$target]}; do
        if [[ $target == "arm64-efi" ]]; then
            make -j CROSS=aarch64-linux-gnu- $output \
                EMBED=$EMBED \
                CERT=$CERT_TRUST_STR \
                TRUST=$CERT_TRUST_STR
        else
            make -j $output \
                EMBED=$EMBED \
                CERT=$CERT_TRUST_STR \
                TRUST=$CERT_TRUST_STR
        fi
    done
done

# Copy output files
output_dir="/output"
declare -A output_files=(
    ["bin-x86_64-efi/ipxe.iso"]="$output_dir/ipxe-x86_64-efi.iso"
    ["bin-x86_64-efi/ipxe.usb"]="$output_dir/ipxe-x86_64-efi.usb"
    ["bin-x86_64-pcbios/ipxe.iso"]="$output_dir/ipxe-x86_64-bios.iso"
    ["bin-x86_64-pcbios/ipxe.usb"]="$output_dir/ipxe-x86_64-bios.usb"
    ["bin-x86_64-pcbios/ipxe.vhd"]="$output_dir/ipxe-x86_64-bios.vhd"
    ["bin-arm64-efi/ipxe.iso"]="$output_dir/ipxe-arm64-efi.iso"
    ["bin-arm64-efi/ipxe.usb"]="$output_dir/ipxe-arm64-efi.usb"
)

echo "Copying output files"
for src in "${!output_files[@]}"; do
    cp $src ${output_files[$src]}
done

# Generate SHA256 sum for each file
cd $output_dir || exit 1
sha256sum ./* > sha256sum.txt
