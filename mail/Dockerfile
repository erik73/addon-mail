ARG BUILD_FROM==ghcr.io/hassio-addons/base/amd64:9.0.1
# hadolint ignore=DL3006
FROM ${BUILD_FROM}

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Setup base
RUN apk add --no-cache \
    mariadb-client=10.5.8-r0 \
    nginx=1.18.0-r13 \ 
    php7-fpm=7.4.14-r0 \
    php7-imap=7.4.14-r0 \
    php7-session=7.4.14-r0 \
    php7-json7.4.14-r0 \
    php7-opcache=7.4.14-r0 \
    php7-mbstring=7.4.14-r0 \
    php7-mysqli=7.4.14-r0 \
    php7-pdo_mysql=7.4.14-r0 \
    postfix=3.5.9-r0 \
    postfix-mysql=3.5.9-r0 \
    dovecot=2.3.13-r0 \
    dovecot-lmtpd=2.3.13-r0 \
    dovecot-mysql=2.3.13-r0 \
    dovecot-pigeonhole-plugin=2.3.13-r0 \
    rspamd-client=2.7-r0 \
    && mkdir /var/www/postfixadmin \
    && curl -L -s "https://github.com/postfixadmin/postfixadmin/archive/postfixadmin-3.3.3.tar.gz" \
        | tar zxvf - -C /var/www/postfixadmin --strip-components=1; \
        mkdir -p /var/www/postfixadmin/templates_c; \
        chown -R nginx: /var/www/postfixadmin; \
        mkdir -p /etc/postfix/sql \
    && rm -f -r \
        /tmp/* \
    && S6_ARCH="${BUILD_ARCH}" \
    && if [ "${BUILD_ARCH}" = "i386" ]; then S6_ARCH="x86"; fi \
    && if [ "${BUILD_ARCH}" = "armv7" ]; then S6_ARCH="arm"; fi \
    && curl -L -s "https://github.com/just-containers/socklog-overlay/releases/download/v3.1.0-2/socklog-overlay-${S6_ARCH}.tar.gz" \
        | tar zxvf - -C /;
# Copy data for add-on
COPY rootfs /

# Build arguments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Erik Hilton <erikhilton73@gmail.com>" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.vendor="Erik73 Hassio-Addons" \
    org.opencontainers.image.authors="Erik Hilton <erikhilton73@gmail.com>" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://github.com/erik73/hassio-addons" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}
