#!/bin/bash

set -e
set -x

rustup update
sudo dnf update --assumeyes

hg revert --all --no-backup
hg pull

set +x
echo
echo "Most recent release version git tags:"
hg tags | grep -P 'FIREFOX(_[0-9]+)+_RELEASE' | sort --version-sort | tail -10
echo
echo -n "Select tag to checkout: "; read tag
set -x

hg update -r "$tag"
cat browser/config/version.txt
./mach --no-interactive bootstrap --application-choice browser
