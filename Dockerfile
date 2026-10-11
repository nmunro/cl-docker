ARG SBCL_VERSION=sbcl-bin/2.6.9

FROM cgr.dev/chainguard/wolfi-base AS build

ARG SBCL_VERSION

ENV ROSWELL_HOME=/opt/roswell
ENV PATH="/opt/bin:/opt/roswell/bin:${PATH}"

RUN apk add --no-cache patchelf git build-base automake autoconf curl-dev
RUN git clone https://github.com/roswell/roswell.git
WORKDIR /roswell
RUN sh bootstrap \
    && ./configure --prefix=/opt \
    && make \
    && make install \
    && ros setup \
    && ros install ${SBCL_VERSION} \
    && ros use ${SBCL_VERSION} \
    && ros install qlot


FROM cgr.dev/chainguard/wolfi-base AS prod

ENV ROSWELL_HOME=/opt/roswell
ENV PATH="/opt/bin:/opt/roswell/bin:${PATH}"

COPY --from=build /opt /opt

RUN apk add --no-cache curl ca-certificates
