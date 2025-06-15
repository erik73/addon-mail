#!/bin/sh

umask 077

SSLDIR=/etc/ssl/dovecot

CERTDIR=$SSLDIR


CERTFILE=$CERTDIR/server.pem
KEYFILE=$CERTDIR/server.key

if [ ! -d "$CERTDIR" ]; then
  echo "$CERTDIR directory doesn't exist"
  exit 1
fi

if [ -f "$CERTFILE" ]; then
  echo "$CERTFILE already exists, won't overwrite"
  exit 1
fi

if [ -f "$KEYFILE" ]; then
  echo "$KEYFILE already exists, won't overwrite"
  exit 1
fi

openssl req -new -x509 -nodes -config /etc/dovecot/dovecot-openssl.cnf -out "$CERTFILE" -keyout "$KEYFILE" -days 365 || exit 2
chmod 0600 "$KEYFILE"
echo
openssl x509 -subject -fingerprint -noout -in "$CERTFILE" || exit 2