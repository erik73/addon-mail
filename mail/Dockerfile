ARG BUILD_FROM=ghcr.io/erik73/base/amd64:2.0.9
# hadolint ignore=DL3006
FROM ${BUILD_FROM}

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ARG S6_OVERLAY_VERSION="v3.1.4.2"
ARG POSTFIXADMIN_VERSION="3.3.13"

# Build arguments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

# Setup base
RUN apk add --no-cache \
    mariadb-client=10.6.12-r0 \
    nginx=1.22.1-r0 \ 
    php81=8.1.18-r0 \
    php81-fpm=8.1.18-r0 \
    php81-imap=8.1.18-r0 \
    php81-session=8.1.18-r0 \
    php81-opcache=8.1.18-r0 \
    php81-mbstring=8.1.18-r0 \
    php81-mysqli=8.1.18-r0 \
    php81-pdo_mysql=8.1.18-r0 \
    postfix=3.7.4-r0 \
    postfix-mysql=3.7.4-r0 \
    dovecot=2.3.20-r7 \
    dovecot-lmtpd=2.3.20-r7 \
    dovecot-mysql=2.3.20-r7 \
    dovecot-pigeonhole-plugin=2.3.20-r7 \
    rspamd-client=3.5-r1 \
    && curl -L -s "https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/syslogd-overlay-noarch.tar.xz" \
        | tar -C / -Jxpf - \
    && mkdir /var/www/postfixadmin \
    && curl -L -s "https://github.com/postfixadmin/postfixadmin/archive/postfixadmin-${POSTFIXADMIN_VERSION}.tar.gz" \
        | tar zxvf - -C /var/www/postfixadmin --strip-components=1; \
        mkdir -p /var/www/postfixadmin/templates_c; \
        chown -R nginx: /var/www/postfixadmin; \
        mkdir -p /etc/postfix/sql \
    && rm -f -r \
        /tmp/* \
    && mkdir -p /run/systemd/journal

# Copy data for add-on
COPY rootfs /

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
