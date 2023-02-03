FROM docker.io/ubuntu:latest

RUN echo "Installing dependencies"

RUN whoami

RUN apt-get update -y
RUN apt-get install -y gcc binutils make perl-base liblzma-dev mtools genisoimage syslinux dos2unix isolinux qemu-utils gcc-aarch64-linux-gnu
RUN apt-get upgrade -y

RUN echo "Copying files"

COPY src /src

RUN echo "Fixing files"
RUN dos2unix src/util/genfsimg
RUN chmod +x src/util/genfsimg

RUN dos2unix src/util/elf2efi64
RUN chmod +x src/util/elf2efi64

RUN dos2unix src/util/zbin
RUN chmod +x src/util/zbin

COPY make.sh /make.sh
RUN chmod +x /make.sh

ENTRYPOINT ["/bin/sh", "-c", "/make.sh"]