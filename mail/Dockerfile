ARG BUILD_FROM=ghcr.io/erik73/base/amd64:3.0.29
# hadolint ignore=DL3006
FROM ${BUILD_FROM}

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ARG S6_OVERLAY_VERSION="v3.2.0.2"
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
    mariadb-client=10.11.10-r0 \
    nginx=1.26.2-r0 \ 
    php82=8.2.26-r0 \
    php82-fpm=8.2.26-r0 \
    php82-imap=8.2.26-r0 \
    php82-session=8.2.26-r0 \
    php82-opcache=8.2.26-r0 \
    php82-mbstring=8.2.26-r0 \
    php82-mysqli=8.2.26-r0 \
    php82-pdo_mysql=8.2.26-r0 \
    postfix=3.9.1-r0 \
    postfix-mysql=3.9.1-r0 \
    dovecot=2.3.21.1-r0 \
    dovecot-lmtpd=2.3.21.1-r0 \
    dovecot-mysql=2.3.21.1-r0 \
    dovecot-pigeonhole-plugin=2.3.21.1-r0 \
    rspamd-client=3.8.4-r0 \
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
