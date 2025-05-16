#!/bin/sh

if [ "$(id -u)" = 0 ] ; then
	exec su build -c "sh -e $0"
fi

exec .ci/build.sh
