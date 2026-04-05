FROM cgr.dev/chainguard/wolfi-base 

RUN apk add --no-cache patchelf git build-base automake autoconf curl-dev
RUN git clone https://github.com/roswell/roswell.git
WORKDIR /roswell
RUN sh bootstrap \
    && ./configure \
    && make \
    && make install \
    && ros setup \
    && ros install qlot
