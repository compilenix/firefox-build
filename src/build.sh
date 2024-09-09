#!/usr/bin/zsh

set -e
set -x

env | sort
nice -n 15 ./mach build
./mach package
cp -fv obj-firefox/dist/firefox-*.tar.bz2 /dist/
chmod 0666 /dist/*
