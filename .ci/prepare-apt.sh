#!/bin/sh

if [ "$UID" -ne "0" ] ; then
	exit 0
fi

# https://stackoverflow.com/questions/51026287/ways-to-set-debconf-to-run-non-interactively
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

apt-get -y update
apt-get -y install sudo adduser

adduser --disabled-password build
echo "build ALL=(ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/99-ci
