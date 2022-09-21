#!/usr/bin/zsh

set -e
set -x

rustup update
sudo dnf update --assumeyes
sudo chown -R firefox:firefox "$HOME/patches"
git config fetch.prune true
git reset --hard
git fetch --all
git fetch --tags hg::tags: tag "*"
git cinnabar fsck

set +x
echo
echo "Most recent release version git tags:"
git tag | egrep 'FIREFOX(_[0-9]+)+_RELEASE' | sort --version-sort | tail -10
echo
echo -n "Select git tag to checkout: "; read tag
set -x

git checkout "$tag"
cat browser/config/version.txt
./mach --no-interactive bootstrap --application-choice browser
