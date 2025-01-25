#!/bin/sh

if [ "$UID" -ne "0" ] ; then
	exit 0
fi

echo ">>>> Running .ci/prepare.sh"

set -x

apk upgrade -U

echo "http://mirror.postmarketos.org/postmarketos/master" >> /etc/apk/repositories
echo "http://mirror.postmarketos.org/postmarketos/extra-repos/systemd/master" >> /etc/apk/repositories
apk add -U --allow-untrusted postmarketos-keys

apk add alpine-base alpine-sdk abuild-sudo !openrc

adduser -D build
adduser build abuild
