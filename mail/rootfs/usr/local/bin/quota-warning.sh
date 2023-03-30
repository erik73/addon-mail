#!/bin/sh
# shellcheck disable=SC2086
PERCENT=$1
USER=$2
cat << EOF | /usr/libexec/dovecot/dovecot-lda -d $USER -o "plugin/quota=dict:User quota::noenforcing:proxy::sqlquota"
From: postmaster
Subject: Quota warning

Your mailbox is now $PERCENT% full.
EOF