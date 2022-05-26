#!/usr/bin/zsh

set -e
set -x

nice -n 15 ./mach build
./mach package
cp -fv obj-firefox/dist/firefox-*.tar.bz2 /dist/
