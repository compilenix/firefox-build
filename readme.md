# Requirements
To build the docker image you need at least 2 GB disk space.

To run the container and building firefox you need at least additional 22 GB disk space.

# Usage

Clone and build docker image:

```
git clone https://git.compilenix.org/CompileNix/firefox-build.git
cd firefox-build
docker build -t firefox-build:fedora-32 .
```

Update `mozconfig` to best match your CPU properties and features and also update `MOZ_MAKE_FLAGS` to the result of `echo $(($(nproc) + 2))`. \
The following snippet will help you finding the supported CFLAGS of your CPU:

```
docker run -it --rm firefox-build:fedora-32 /bin/bash
gcc -v -E -x c /dev/null -o /dev/null -march=native 2>&1 | grep /cc1
exit
```

I had to disable AVX2, even my CPU does support it, using `-mno-avx2`.

Now you can build firefox. \
When asked for `Destination directory for Git clone`, enter: `mozilla-unified`

```
mkdir -v dist; chmod -v 0777 dist
docker run -v ./dist:/dist:z -it --rm firefox-build:fedora-32 /bin/bash

python3 bootstrap.py --vcs=git --application-choice browser --no-interactive

# here you may change / update the mozconfig
#vi mozconfig

cd mozilla-unified
git checkout origin/bookmarks/release
cat browser/config/version.txt # to see the version you will be compiling
nice -n 15 ./mach build
./mach package
cp -v obj-x86_64-pc-linux-gnu/dist/firefox-*.tar.bz2 /dist/
```
