#!/bin/sh

if [ "$UID" -ne "0" ] ; then
	exit 0
fi

echo ">>>> Running .ci/prepare.sh"

packages=""
need_usr_merge=""

case "$1" in
	"master"|"v25.12")
		packages="postmarketos-base postmarketos-baselayout alpine-sdk abuild-sudo merge-usr"
		need_usr_merge="1"
		;;

	"v25.06")
		packages="alpine-base alpine-sdk abuild-sudo"
		;;

	*)
		echo "ERROR: missing \$1: takes pmOS binary channel. (either \"master\" or one of the stable releases like \"v25.06\")"
		exit 1
		;;
esac

case "$2" in
	"systemd")
		echo "http://mirror.postmarketos.org/postmarketos/extra-repos/systemd/$1" >> /etc/apk/repositories
		packages="$packages !openrc"
		;;
	"openrc")
		packages="$packages openrc"
		;;
	*)
		echo "ERROR: missing \$2: takes pmOS extra-repos. (either \"systemd\" or \"openrc\")"
		exit 1
		;;
esac

set -x

apk upgrade -U

if [ "$1" = "master" ]; then
	echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
fi

echo "http://mirror.postmarketos.org/postmarketos/$1" >> /etc/apk/repositories

apk add -U --allow-untrusted postmarketos-keys

apk add $packages
if [ $need_usr_merge=1 ]; then
	merge-usr
fi

adduser -D build
adduser build abuild
