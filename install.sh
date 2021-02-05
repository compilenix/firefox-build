#!/bin/bash
set -e

# list options
echo "Options:"
for file in dist/*; do
    echo "  - $(basename ${file})"
done
echo

echo -n "version [firefox.tar.bz2]: "; read version
version=$(echo $version | rev | cut -d . -f 3- | rev)

echo -n "installation target directory [~/bin]: "; read target_dir
if [ ! -d "${target_dir}" ]; then
    target_dir="${HOME}/bin"
fi

set -x
mkdir -pv ~/bin
cp -v "dist/${version}.tar.bz2" ~/bin/
cd ~/bin
if [ -d "${version}" ]; then
    rm -rf "${version}"
fi
mkdir -pv "${version}"
tar -xaf "${version}.tar.bz2" --directory "${target_dir}/${version}"
ln -sfv "${target_dir}/${version}/firefox/firefox" ./
ls -lah --color=auto "${target_dir}/firefox"
