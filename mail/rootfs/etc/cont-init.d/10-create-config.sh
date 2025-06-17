#!/command/with-contenv bashio
# shellcheck disable=SC2086,SC2016
# ==============================================================================
# Home Assistant Add-on: Mailserver
# Configures mailserver
# ==============================================================================

export host
export password
export port
export username
export database

host=$(bashio::services "mysql" "host")
password=$(bashio::services "mysql" "password")
port=$(bashio::services "mysql" "port")
username=$(bashio::services "mysql" "username")
relayhost=$(bashio::config 'smtp_relayhost')
postfixadmin=$(bashio::config 'admin_user')
postfixpassword=$(bashio::config 'admin_password')
myhostname=$(bashio::config 'my_hostname')
domain=$(bashio::config 'domain_name')
relaycredentials=$(bashio::config 'smtp_relayhost_credentials')
messagesizelimit=$(bc <<< "$(bashio::config 'message_size_limit' '10') * 1024000")

adduser -S -D -H syslog
adduser -S -D -H sysllog
addgroup -g 1000 vmail
adduser -D -G vmail -H -h /var/mail/domains -u 1000 -s /sbin/nolgin vmailuser


chmod +x /usr/local/bin/quota-warning.sh
mkdir -p /etc/dovecot/users
chown vmailuser:dovecot /etc/dovecot/users
chmod 440 /etc/dovecot/users

# Add symbolic link to make logging work in older supervisor
if ! readlink /dev/log >/dev/null 2>&1
then
ln -s /run/systemd/journal/dev-log /dev/log
fi

# Ensures the data of the Postfix and Dovecot is stored outside of the container
if ! bashio::fs.directory_exists '/data/mail'; then
    mkdir -p /data/mail
fi

rm -fr /var/mail
ln -s /data/mail /var/mail
mkdir -p /var/mail/vmail/sieve/global
chown -R vmailuser:vmail /var/mail
mkdir -p /var/www/postfixadmin/templates_c; \
chown -R nginx: /var/www/postfixadmin; \

# Modify config files for S6-logging
sed -i 's#^ + .*$# + -^auth\\. -^authpriv\\. -mail\\. $T ${dir}/everything#' /etc/s6-overlay/s6-rc.d/syslogd-log/run
sed -i 's#^ + .*$# + -^auth\\. -^authpriv\\. -mail\\. $T ${dir}/everything#' /run/service/syslogd-log/run.user
sed -i 's#^backtick .*$#backtick -D "n20 s1000000 T 1" line { printcontenv S6_LOGGING_SCRIPT }#' /etc/s6-overlay/s6-rc.d/syslogd-log/run
sed -i 's#^backtick .*$#backtick -D "n20 s1000000 T 1" line { printcontenv S6_LOGGING_SCRIPT }#' /run/service/syslogd-log/run.user
sed -i 's#^s6-socklog .*$#s6-socklog -d3 -U -t3000 -x /run/systemd/journal/dev-log#' /etc/s6-overlay/s6-rc.d/syslogd/run
sed -i 's#^s6-socklog .*$#s6-socklog -d3 -U -t3000 -x /run/systemd/journal/dev-log#' /run/service/syslogd/run.user

# Modify config files
sed -i 's/^user .*$/user = '$username'/' /etc/postfix/sql/*.cf
sed -i 's/^password .*$/password = '$password'/' /etc/postfix/sql/*.cf
sed -i 's/^hosts .*$/hosts = '$host'/' /etc/postfix/sql/*.cf
sed -i 's/^  mysql_host .*$/  mysql_host = '$host'/' /etc/dovecot/conf.d/auth-sql.conf.ext
sed -i 's/^  mysql_user .*$/  mysql_user = '$username'/' /etc/dovecot/conf.d/auth-sql.conf.ext
sed -i 's/^  mysql_password .*$/  mysql_password = '$password'/' /etc/dovecot/conf.d/auth-sql.conf.ext
sed -i "s/postmaster_address = postmaster/postmaster_address = postmaster@${domain}/g" /etc/dovecot/conf.d/20-lmtp.conf
sed -i "s/From: postmaster/From: postmaster@${domain}/g" /usr/local/bin/quota-warning.sh
sed -i "s/@domain/@${domain}/g" /var/www/postfixadmin/config.local.php
sed -i "s/myhostname =/myhostname = ${myhostname}/g" /etc/postfix/main.cf
sed -i "s/message_size_limit =/message_size_limit = ${messagesizelimit}/g" /etc/postfix/main.cf
sed -i "s/        header('X-Frame-Options: DENY');/        header('X-Frame-Options: SAMEORIGIN');/g" /var/www/postfixadmin/common.php
sed -i 's/exec php/exec php84/g' /var/www/postfixadmin/scripts/postfixadmin-cli

if bashio::config.has_value "smtp_relayhost"; then
sed -i "s/relayhost =/relayhost = ${relayhost}/g" /etc/postfix/main.cf
fi

if bashio::config.has_value "smtp_relayhost_credentials"; then
cat << EOF >> /etc/postfix/main.cf
smtp_sasl_auth_enable = yes
smtp_sasl_security_options = noanonymous
smtp_sasl_tls_security_options = noanonymous
smtp_sasl_password_maps =
EOF
sed -i "s/smtp_sasl_password_maps =/smtp_sasl_password_maps = static:${relaycredentials}/g" /etc/postfix/main.cf
fi

if bashio::config.false "letsencrypt_certs"; then
bashio::log.info "Self-signed certs will be used..."
/usr/local/bin/mkcert.sh
fi

if bashio::config.true "letsencrypt_certs"; then
bashio::log.info "Let's Encrypt certs will be used..."
sed -i 's~^smtpd_tls_cert.*$~smtpd_tls_cert_file = /ssl/fullchain.pem~g' /etc/postfix/main.cf
sed -i 's~^smtpd_tls_key.*$~smtpd_tls_key_file = /ssl/privkey.pem~g' /etc/postfix/main.cf
sed -i 's~^ssl_server_cert_file.*$~ssl_server_cert_file = /ssl/fullchain.pem~g' /etc/dovecot/conf.d/10-ssl.conf
sed -i 's~^ssl_server_key_file.*$~ssl_server_key_file = /ssl/privkey.pem~g' /etc/dovecot/conf.d/10-ssl.conf
fi

database=$(\
    mariadb \
        -u "${username}" -p"${password}" \
        -h "${host}" -P "${port}" \
        --skip-column-names \
        --skip-ssl \
        -e "SHOW DATABASES LIKE 'postfixadmin';"
)

if ! bashio::var.has_value "${database}"; then
    bashio::log.info "Creating database for postfixadmin"
    mariadb \
        -u "${username}" -p"${password}" \
        --skip-ssl \
        -h "${host}" -P "${port}" \
            < /etc/postfix/createdb.sql
php84 /var/www/postfixadmin/public/upgrade.php
/var/www/postfixadmin/scripts/postfixadmin-cli admin add ${postfixadmin}@${domain} --superadmin 1 --active 1 --password ${postfixpassword} --password2 ${postfixpassword}
/var/www/postfixadmin/scripts/postfixadmin-cli domain add ${domain}
fi

#Run the DB upgrade script and set the superadmin user and password on startup
php84 /var/www/postfixadmin/public/upgrade.php
/var/www/postfixadmin/scripts/postfixadmin-cli admin update ${postfixadmin}@${domain} --superadmin 1 --active 1 --password ${postfixpassword} --password2 ${postfixpassword}

newaliases

#Remove old sieve files so that we always have the correct ones

rm -f /var/mail/vmail/sieve/global/*

if ! bashio::fs.file_exists '/var/mail/vmail/sieve/global/spam-global.sieve'; then
cat << EOF >> /var/mail/vmail/sieve/global/spam-global.sieve
require ["fileinto","mailbox"];

if anyof(
    header :contains ["X-Spam-Flag"] "YES",
    header :contains ["X-Spam"] "Yes",
    header :contains ["Subject"] "*** SPAM ***"
    )
{
    fileinto :create "Spam";
    stop;
}
EOF

  cat << EOF >> /var/mail/vmail/sieve/global/report-spam.sieve
require ["vnd.dovecot.pipe", "copy", "imapsieve"];
pipe :copy "rspamc" ["-h", "32b8266a-mailfilter:11334", "learn_ham"];
EOF

  cat << EOF >> /var/mail/vmail/sieve/global/report-ham.sieve
require ["vnd.dovecot.pipe", "copy", "imapsieve"];
pipe :copy "rspamc" ["-h", "32b8266a-mailfilter:11334", "learn_ham"];
EOF

chown -R vmailuser:vmail /var/mail/

fi

if bashio::config.false "enable_mailfilter"; then
  rm -f -r \
  /etc/dovecot/conf.d/20-managesieve.conf \
  /etc/dovecot/conf.d/90-sieve.conf
fi

if bashio::config.true "enable_mailfilter"; then
    bashio::log.info "Mailfilter enabled."
    bashio::log.info "Configuring connection to Mailfilter addon"
    cat << EOF >> /etc/postfix/main.cf
milter_protocol = 6
milter_mail_macros = i {mail_addr} {client_addr} {client_name} {auth_authen}
milter_default_action = accept
smtpd_milters = inet:32b8266a-mailfilter:11332
EOF

fi
