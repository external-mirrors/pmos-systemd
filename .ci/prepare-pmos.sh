#!/bin/sh

if [ "$UID" -ne "0" ] ; then
	exit 0
fi

echo ">>>> Running .ci/prepare.sh"

quirk_v24_12=""

case "$1" in
	"master"|"v25.06")
		;;

	"v24.12")
		quirk_v24_12="1"
		;;

	*)
		echo "ERROR: missing \$1: takes pmOS binary channel. (either \"master\" or one of the stable releases like \"v25.06\")"
		exit 1
		;;
esac


set -x

apk upgrade -U

echo "http://mirror.postmarketos.org/postmarketos/$1" >> /etc/apk/repositories
echo "http://mirror.postmarketos.org/postmarketos/extra-repos/systemd/$1" >> /etc/apk/repositories
apk add -U --allow-untrusted postmarketos-keys

packages="alpine-base alpine-sdk abuild-sudo !openrc"
if [ "$quirk_v24_12" = "1" ]; then
	packages="${packages//!openrc}"
fi

apk add $packages

adduser -D build
adduser build abuild
