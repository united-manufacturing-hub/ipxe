FROM docker.io/ubuntu:latest

RUN echo "Installing dependencies"

RUN sed -i 's|http://.*.ubuntu.com|http://ftp.halifax.rwth-aachen.de|g' /etc/apt/sources.list
RUN cat /etc/apt/sources.list


RUN apt-get update -y && apt-get install apt-transport-https apt-utils -y
RUN apt-get upgrade -y
RUN apt-get update -y && apt-get install -y gcc binutils make perl-base liblzma-dev mtools genisoimage syslinux dos2unix isolinux qemu-utils gcc-aarch64-linux-gnu git wget

ARG CACHEBUST
RUN echo "Cachebust: $CACHEBUST"

# Clone iPXE
RUN echo "Cloning iPXE"
RUN git clone https://github.com/ipxe/ipxe.git /ipxe

RUN echo "Copying files"
RUN cp -r /ipxe/src /src

# Generating elf2efi
RUN git clone https://github.com/davmac314/elf2efi.git
RUN cd elf2efi && make -j && ls -lah && cp elf2efi64 /src/util/elf2efi64

# Apply patches using git
RUN echo "Applying patches"
## 94 (https://github.com/ipxe/ipxe/pull/94) ##
RUN echo "Applying patch 94"
#https://patch-diff.githubusercontent.com/raw/ipxe/ipxe/pull/94.patch
RUN wget https://patch-diff.githubusercontent.com/raw/ipxe/ipxe/pull/94.patch -O /tmp/94.patch
RUN git apply /tmp/94.patch

# Fix files
RUN echo "Fixing files"
RUN dos2unix /src/util/genfsimg
RUN chmod +x /src/util/genfsimg

# Copy config files
COPY config/embed.ipxe /src/embed.ipxe
COPY config/ipxe.iso /src/ipxe.iso
COPY config/*.pem /src/
COPY config/general.h /src/config/general.h
COPY config/crypto.h /src/config/crypto.h

# Ensure at least one .pem file was copied
RUN if [ ! -f /src/*.pem ]; then echo "No .pem files found"; exit 1; fi

WORKDIR /src
RUN echo "Building dependencies"
RUN make -j all
WORKDIR /

RUN chmod +x /src/util/elf2efi64

RUN chmod +x /src/util/zbin

COPY make.sh /make.sh
RUN chmod +x /make.sh


ENTRYPOINT ["/bin/sh", "-c", "/make.sh"]
