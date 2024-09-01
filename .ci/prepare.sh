#!/bin/sh

if [ "$UID" -ne "0" ] ; then
	exit 0
fi

echo ">>>> Running .ci/prepare.sh"

set -x

apk upgrade -U

echo "@pmos http://mirror.postmarketos.org/postmarketos/staging/systemd/master" >> /etc/apk/repositories
apk add -U --allow-untrusted postmarketos-keys@pmos

apk add alpine-base@pmos alpine-sdk abuild-sudo !openrc

adduser -D build
adduser build abuild
