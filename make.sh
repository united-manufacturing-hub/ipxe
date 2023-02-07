cd /src || exit 1

# Remove old build files
rm -rf bin-*

echo "Building x86_64-efi"
make -j bin-x86_64-efi/ipxe.iso EMBED=embed.ipxe CERT=ca.pem,isrgrootx1.pem,lets-encrypt-r3.pem TRUST=ca.pem,isrgrootx1.pem,lets-encrypt-r3.pem
make -j bin-x86_64-efi/ipxe.usb EMBED=embed.ipxe CERT=ca.pem,isrgrootx1.pem,lets-encrypt-r3.pem TRUST=ca.pem,isrgrootx1.pem,lets-encrypt-r3.pem

echo "Building x86_64-bios"
make -j bin-x86_64-pcbios/ipxe.iso EMBED=embed.ipxe CERT=ca.pem,isrgrootx1.pem,lets-encrypt-r3.pem TRUST=ca.pem,isrgrootx1.pem,lets-encrypt-r3.pem
make -j bin-x86_64-pcbios/ipxe.usb EMBED=embed.ipxe CERT=ca.pem,isrgrootx1.pem,lets-encrypt-r3.pem TRUST=ca.pem,isrgrootx1.pem,lets-encrypt-r3.pem
make -j bin-x86_64-pcbios/ipxe.vhd EMBED=embed.ipxe CERT=ca.pem,isrgrootx1.pem,lets-encrypt-r3.pem TRUST=ca.pem,isrgrootx1.pem,lets-encrypt-r3.pem

# arm64-efi
echo "Building arm64-efi"
make -j CROSS=aarch64-linux-gnu- bin-arm64-efi/ipxe.iso EMBED=embed.ipxe CERT=ca.pem,isrgrootx1.pem,lets-encrypt-r3.pem TRUST=ca.pem,isrgrootx1.pem,lets-encrypt-r3.pem
make -j CROSS=aarch64-linux-gnu- bin-arm64-efi/ipxe.usb EMBED=embed.ipxe CERT=ca.pem,isrgrootx1.pem,lets-encrypt-r3.pem TRUST=ca.pem,isrgrootx1.pem,lets-encrypt-r3.pem

echo "Copying output files"

cp bin-x86_64-efi/ipxe.iso /output/ipxe-x86_64-efi.iso
cp bin-x86_64-efi/ipxe.usb /output/ipxe-x86_64-efi.usb

cp bin-x86_64-pcbios/ipxe.iso /output/ipxe-x86_64-bios.iso
cp bin-x86_64-pcbios/ipxe.usb /output/ipxe-x86_64-bios.usb
cp bin-x86_64-pcbios/ipxe.vhd /output/ipxe-x86_64-bios.vhd

cp bin-arm64-efi/ipxe.iso /output/ipxe-arm64-efi.iso
cp bin-arm64-efi/ipxe.usb /output/ipxe-arm64-efi.usb

# Generate SHA256 sum for each file
cd /output || exit 1
sha256sum * > sha256sum.txt
