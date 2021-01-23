ARG BUILD_FROM
FROM $BUILD_FROM

ARG BUILD_ARCH

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Setup base
RUN apk add --no-cache \
    mariadb-client \
    nginx \ 
    php7-fpm \
    php7-cli \
    php7-imap \
    php7-session \
    php7-json \
    php7-opcache \
    php7-mbstring \
    php7-mysqli \
    php7-pdo_mysql \
    postfix \
    postfix-mysql \
    dovecot \
    dovecot-lmtpd \
    dovecot-mysql \
    dovecot-pigeonhole-plugin \
    rspamd-client \
    && mkdir /var/www/postfixadmin \
    && curl -L -s --ipv4 "https://github.com/postfixadmin/postfixadmin/archive/postfixadmin-3.3.3.tar.gz" \
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
ARG BUILD_DATE
ARG BUILD_REF
ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="Mailserver" \
    io.hass.description="Mailserver: Complete mail server solution for Home Assistant" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Erik Hilton <erikhilton73@gmail.com>" \
    org.opencontainers.image.title="Mailserver" \
    org.opencontainers.image.description="Mailserver: Complete mail server solution for Home Assistant" \
    org.opencontainers.image.vendor="Erik73 Hassio-Addons" \
    org.opencontainers.image.authors="Erik Hilton <erikhilton73@gmail.com>" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}
