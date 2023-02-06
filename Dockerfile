FROM docker.io/ubuntu:latest

RUN echo "Installing dependencies"

RUN sed -i 's|http://.*.ubuntu.com|http://ftp.halifax.rwth-aachen.de|g' /etc/apt/sources.list
RUN cat /etc/apt/sources.list


RUN apt-get update -y && apt-get install apt-transport-https apt-utils -y
RUN apt-get upgrade -y
RUN apt-get update -y && apt-get install -y gcc binutils make perl-base liblzma-dev mtools genisoimage syslinux dos2unix isolinux qemu-utils gcc-aarch64-linux-gnu git

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

RUN echo "Fixing files"
RUN dos2unix /src/util/genfsimg
RUN chmod +x /src/util/genfsimg

# Copy config files
COPY config/embed.ipxe /src/embed.ipxe
COPY config/ipxe.iso /src/ipxe.iso
COPY config/isrg-root-x2.pem /src/isrg-root-x2.pem
COPY config/isrgrootx1.pem /src/isrgrootx1.pem
COPY config/lets-encrypt-r3.pem /src/lets-encrypt-r3.pem
COPY config/ca.pem /src/ca.pem
COPY config/general.h /src/config/general.h

WORKDIR /src
RUN echo "Building dependencies"
RUN make -j all
WORKDIR /

RUN chmod +x /src/util/elf2efi64

RUN chmod +x /src/util/zbin

COPY make.sh /make.sh
RUN chmod +x /make.sh


ENTRYPOINT ["/bin/sh", "-c", "/make.sh"]
