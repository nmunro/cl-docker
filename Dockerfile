FROM cgr.dev/chainguard/wolfi-base AS wolfi-sbcl-builder

ARG SBCL_BOOT_VERSION=1.4.2      # whatever version has a matching binary tarball
ARG SBCL_NEW_VERSION=2.5.11

RUN apk update && apk add --no-cache curl build-base linux-headers coreutils

WORKDIR /builder

# 1) Download & install binary SBCL as bootstrap
RUN curl -L -o sbcl-boot.tar.bz2 https://downloads.sourceforge.net/project/sbcl/sbcl/${SBCL_BOOT_VERSION}/sbcl-${SBCL_BOOT_VERSION}-arm64-linux-binary.tar.bz2 \
 && tar -xjf sbcl-boot.tar.bz2 \
 && cd sbcl-${SBCL_BOOT_VERSION}-arm64-linux \
 && sh install.sh

# 2) Download newer SBCL source
RUN curl -L -o sbcl-src.tar.bz2 https://prdownloads.sourceforge.net/sbcl/sbcl-${SBCL_NEW_VERSION}-source.tar.bz2 \
 && tar -xjf sbcl-src.tar.bz2

# 3) Build newer SBCL using the binary one as host
WORKDIR /builder/sbcl-${SBCL_NEW_VERSION}
RUN sh make.sh --prefix=/opt/sbcl-${SBCL_NEW_VERSION} \
 && INSTALL_ROOT=/opt/sbcl-${SBCL_NEW_VERSION} sh install.sh


FROM cgr.dev/chainguard/wolfi-base AS wolfi-roswell-builder

COPY --from=wolfi-sbcl-builder /opt /opt

RUN apk update && apk add --no-cache git build-base automake autoconf curl-dev
RUN git clone https://github.com/roswell/roswell.git
WORKDIR /roswell
RUN sh bootstrap \
    && ./configure \
    && make \
    && make install \
    && ros setup
