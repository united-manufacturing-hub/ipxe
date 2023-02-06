FROM docker.io/ubuntu:latest

RUN echo "Installing dependencies"

RUN apt-get update -y && apt-get install -y gcc binutils make perl-base liblzma-dev mtools genisoimage syslinux dos2unix isolinux qemu-utils gcc-aarch64-linux-gnu git

RUN echo "Copying files"

COPY src /src

# Generating elf2efi
RUN git clone https://github.com/davmac314/elf2efi.git
RUN cd elf2efi && make -j && cp elf2efi64 /src/util/elf2efi64

RUN echo "Fixing files"
RUN dos2unix /src/util/genfsimg
RUN chmod +x /src/util/genfsimg

WORKDIR /src
RUN echo "Building dependencies"
RUN make -j all
WORKDIR /

RUN chmod +x /src/util/elf2efi64

RUN dos2unix /src/util/zbin
RUN chmod +x /src/util/zbin

COPY make.sh /make.sh
RUN chmod +x /make.sh


ENTRYPOINT ["/bin/sh", "-c", "/make.sh"]
