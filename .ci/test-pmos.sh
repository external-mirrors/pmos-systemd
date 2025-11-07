#!/bin/sh

if [ "$(id -u)" = 0 ] ; then
	exec su build -c "sh -e $0"
fi

_step="${CI_ABUILD_STEP:-check}"

cp .ci/APKBUILD ./APKBUILD

abuild -K deps $_step
