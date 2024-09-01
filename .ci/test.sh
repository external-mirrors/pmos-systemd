#!/bin/sh

if [ "$(id -u)" = 0 ] ; then
	exec su build -c "sh -e $0"
fi

cp .ci/APKBUILD ./APKBUILD

abuild -K deps check
