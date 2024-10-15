#!/bin/bash
# vim: sw=4 et
set -e

function ask_yn {
    select yn in "Yes" "No"; do
        case $yn in
            Yes)
                ask_yn_y_callback
                break;;
            No)
                ask_yn_n_callback
                break;;
        esac
    done
}

function reset-ask_yn {
    function ask_yn_y_callback() { echo -n; }
    function ask_yn_n_callback() { echo -n; }
}
reset-ask_yn

current_firefox_version=$(firefox --version)

# list options
echo "Options:"
for file in $(ls --color=never dist/* | sort --version-sort | tail -5); do
    echo "  - $(basename ${file})"
done
echo

echo -n "version [firefox.tar.bz2]: "; read version
version=$(echo $version | rev | cut -d . -f 3- | rev)

echo -n "installation target directory [~/bin]: "; read install_dir
if [ ! -d "$install_dir" ]; then
    install_dir="$HOME/bin"
fi

# backup current firefox profiles
function ask_yn_y_callback() {
    set -x
    target_dir="/tmp/$UID/.mozilla/$current_firefox_version"
    if [ -d "$target_dir" ]; then
        rm -rf "$target_dir"
    fi
    mkdir -pv "$target_dir"
    rsync -rav "$HOME/.mozilla/firefox" "$target_dir"
    set +x
    echo "firefox profiles backup location: \"$target_dir\""
}
if [ -d "$HOME/.mozilla/firefox" ]; then
    echo "backup firefox profiles?"
    ask_yn
    reset-ask_yn
fi

# extract firefox
function ask_yn_y_callback() {
    set -x
    mkdir -pv ~/bin
    cp -v "dist/${version}.tar.bz2" ~/bin/
    cd ~/bin
    if [ -d "${version}" ]; then
        rm -rf "${version}"
    fi
    mkdir -pv "${version}"
    tar -xaf "${version}.tar.bz2" --directory "${install_dir}/${version}"
    set +x
}
if [ -d "$HOME/.mozilla/firefox" ]; then
    echo "extract firefox $version into \"$install_dir\"?"
    ask_yn
    reset-ask_yn
fi

# link firefox
function ask_yn_y_callback() {
    set -x
    cd ~/bin
    ln -sfv "${install_dir}/${version}/firefox/firefox" ./
    cp -v "${install_dir}/${version}/firefox/browser/chrome/icons/default/default128.png" "firefox.png"
    ls -lah --color=auto "${install_dir}/firefox"
    set +x
}
if [ -d "$HOME/.mozilla/firefox" ]; then
    echo "link firefox into ~/bin?"
    ask_yn
    reset-ask_yn
fi

# install firefox desktop file into ~/.local/share/applications
function ask_yn_y_callback() {
    set -x
    mkdir -pv "$HOME/bin"
    cp -v "./firefox.desktop" "/tmp/firefox.desktop.tmpl"
    envsubst < "/tmp/firefox.desktop.tmpl" > "/tmp/firefox.desktop"
    desktop-file-install --dir="$HOME/.local/share/applications" --rebuild-mime-info-cache "/tmp/firefox.desktop"
    rm -v "/tmp/firefox.desktop.tmpl" "/tmp/firefox.desktop"
    set +x
}
set +x
echo "install firefox desktop file into ~/.local/share/applications?"
ask_yn
reset-ask_yn

