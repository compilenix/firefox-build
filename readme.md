# Requirements
To build the docker image you need at least 2 GB disk space.

To run the container and building firefox you need at least additional 22 GB disk space.

# Usage

Clone and build docker image:

```sh
git clone https://git.compilenix.org/CompileNix/firefox-build.git
cd firefox-build
docker build -t firefox-build:fedora-32 .
```

Update `mozconfig` to best match your CPU properties and features and also update `MOZ_MAKE_FLAGS` to the result of `echo $(($(nproc) + 2))`. \
The following snippet will help you finding the supported CFLAGS of your CPU:

```sh
docker run -it --rm firefox-build:fedora-32 /bin/bash
gcc -v -E -x c /dev/null -o /dev/null -march=native 2>&1 | grep /cc1
exit
```

I had to disable AVX2, even my CPU does support it, using `-mno-avx2`.

Now you can build firefox. \
When asked for `Destination directory for Git clone`, enter: `mozilla-unified`

```sh
docker build -t firefox-build:fedora-32 .
mkdir -v dist mozilla-unified mozbuild; chmod -v 0777 dist mozilla-unified mozbuild
docker run -v ./dist:/dist:z -v ./mozbuild:/src/.mozbuild:z -v ./mozilla-unified:/src/mozilla-unified:z -it --rm firefox-build:fedora-32 /bin/bash
git clone https://github.com/glandium/git-cinnabar.git /src/.mozbuild/git-cinnabar
git cinnabar download

python3 bootstrap.py --vcs=git --application-choice browser --no-interactive

cd mozilla-unified
git checkout origin/bookmarks/release
cat browser/config/version.txt # to see the version you will be building
nice -n 15 ./mach build; ./mach package; cp -v obj-ff-rel-opt/dist/firefox-*.tar.bz2 /dist/
```

# Subsequent builds

Update your `mozconfig`, if you want. Then execute the snippet below. \
When asked for `Destination directory for Git clone`, enter nothing (hit enter).

```sh
docker build -t firefox-build:fedora-32 .
docker run -v ./dist:/dist:z -v ./mozbuild:/src/.mozbuild:z -v ./mozilla-unified:/src/mozilla-unified:z -it --rm firefox-build:fedora-32 /bin/bash
sudo dnf update --refresh --assumeyes
cd mozilla-unified
git reset --hard
git pull --all
git checkout origin/bookmarks/release
cat browser/config/version.txt # to see the version you will be building
./mach bootstrap --application-choice browser --no-interactive
nice -n 15 ./mach build; ./mach package; cp -v obj-ff-rel-opt/dist/firefox-*.tar.bz2 /dist/
```

# Paches

Apply before `nice -n 15 ./mach build`.

## Disable "Select all" when clicking into UrlBar

File: `/src/mozilla-unified/browser/components/urlbar/UrlbarInput.jsm` \
Line: 1970

```js
_maybeSelectAll() {
    return;
    // ...
```
