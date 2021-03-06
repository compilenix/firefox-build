# Requirements
To build the docker image you need at least 2 GB disk space.

To run the container and building firefox you need at least additional 22 GB disk space.

# Usage

Clone and build docker image:

```sh
git clone https://git.compilenix.org/CompileNix/firefox-build.git
cd firefox-build
docker build -t firefox-build:fedora-33 .
```

Find your CPU cache sizes and update the `mozconfig`:

```sh
docker run -it --rm firefox-build:fedora-33 /bin/bash
gcc -v -E -x c /dev/null -o /dev/null -march=native 2>&1 | grep /cc1
exit
```

Now you can build firefox. \
When asked for `Destination directory for Git clone`, enter: `mozilla-unified`

```sh
docker build -t firefox-build:fedora-33 .
mkdir -v dist mozilla-unified mozbuild; chmod -v 0777 dist mozilla-unified mozbuild
docker run -v ./dist:/dist -v ./mozbuild:/src/.mozbuild -v ./mozilla-unified:/src/mozilla-unified -v ./mozconfig:/src/mozconfig -it --rm firefox-build:fedora-33 /bin/bash
git clone https://github.com/glandium/git-cinnabar.git /src/.mozbuild/git-cinnabar
git cinnabar download

python3 bootstrap.py --vcs=git --application-choice browser --no-interactive

cd mozilla-unified
git fetch --tags hg::tags: tag "*"
git tag | egrep 'FIREFOX(_[0-9]+)+_RELEASE' | tail -10
git checkout FIREFOX_80_RELEASE
cat browser/config/version.txt # to verify the version you will be building
# At this point you may want to apply your custom patches
nice -n 15 ./mach build && ./mach package && cp -v obj-ff-rel-opt/dist/firefox-*.tar.bz2 /dist/
exit
./install.sh # you may run this with sudo if your current user is not permitted to write into the installation directory (default is ~/bin/)
```

# Subsequent builds

Update your `mozconfig`, if you want. Then execute the snippet below. \
When asked for `Destination directory for Git clone`, enter nothing (hit enter).

```sh
docker build -t firefox-build:fedora-33 .
docker run -v $(pwd)/dist:/dist -v $(pwd)/mozbuild:/src/.mozbuild -v $(pwd)/mozilla-unified:/src/mozilla-unified -v $(pwd)/mozconfig:/src/mozconfig -it --rm firefox-build:fedora-33 /bin/bash
sudo dnf update --refresh --assumeyes
cd mozilla-unified
git reset --hard
git pull --all
git fetch --tags hg::tags: tag "*"
git cinnabar fsck
git tag | egrep 'FIREFOX(_[0-9]+)+_RELEASE' | tail -10
git checkout FIREFOX_80_RELEASE
cat browser/config/version.txt # to verify the version you will be building
./mach bootstrap --application-choice browser --no-interactive
# At this point you may want to apply your custom patches
nice -n 15 ./mach build && ./mach package && cp -fv obj-ff-rel-opt/dist/firefox-*.tar.bz2 /dist/
exit
./install.sh # you may run this with sudo if your current user is not permitted to write into the installation directory (default is ~/bin/)
```

# Paches

Apply before `nice -n 15 ./mach build`.

## Disable "Select all" when clicking into UrlBar

```sh
sed -Ei '/_maybeSelectAll\(\)\ \{$/a return;' browser/components/urlbar/UrlbarInput.jsm
```

This is what we are looking for:

```js
_maybeSelectAll() {
    return;
    // ...
```

# Building other branches / tags / bookmarks than "bookmarks/release"
After you've `git clone`'d or `git fetch`'ed and `cd`'ed into `mozilla-unified`, fetch the tags from origin with:

```sh
# this may take a while
git fetch --tags hg::tags: tag "*"
```

Now find the tag you want to build, i.e.:

```sh
# get the 10 most recent firefox release tags
git tag | egrep 'FIREFOX(_[0-9]+)+_RELEASE' | tail -10

# get the 10 most recent firefox esr release tags
git tag | egrep 'FIREFOX(_[0-9]+)+_[0-9]esr_RELEASE' | tail -10
```

# Troubleshooting
## Hardware specific compiler flags
If you want to enable or disable specific cpu features, here you can get info about what the compilers detect on your machine

```sh
docker run -it --rm firefox-build:fedora-33 /bin/bash
# C and C++ flags:
gcc -v -E -x c /dev/null -o /dev/null -march=native 2>&1 | grep /cc1
# Rust flags
rustc -C help
rustc --print target-cpus
rustc --print target-features
exit
```

I had to disable AVX2, even my CPU does support it, using `-mno-avx2` for the `CFLAGS` and `-C target-features=-avx2` for `RUSTFLAGS`.

## Compile error: error: options `-C embed-bitcode=no` and `-C lto` are incompatible
This "issue" came up with the release of Rust 1.45.

[Bugzilla issue](https://bugzilla.mozilla.org/show_bug.cgi?id=1640982)

My workaround; downgrade Rust to 1.44.1:
```sh
# run this after "bootstrap" and before "./mach build"
source ~/.cargo/env
rustup default 1.44.1
```

## No rule to make target 'alg2268.c', needed by 'alg2268.obj'. Stop.
My workaround;

```sh
./mach clobber
./mach bootstrap --application-choice browser --no-interactive
# run mach make again
```
