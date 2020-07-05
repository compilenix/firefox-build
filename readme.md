# Usage

```
docker build -t firefox-build:fedora-31 .
mkdir -v dist; chmod -v 0777 dist
docker run -v ./dist:/dist -it --rm firefox-build:fedora-31 /bin/bash
python bootstrap.py --vcs=git --application-choice browser --no-interactive
cd mozilla-unified
git checkout origin/bookmarks/release
nice -n 15 ./mach build
./mach package
cp -v obj-x86_64-pc-linux-gnu/dist/firefox-*.tar.bz2 /dist/
```

# CFLAGS

```
docker build -t firefox-build:fedora-31 .
docker run -it --rm firefox-build:fedora-31 /bin/bash
gcc -v -E -x c /dev/null -o /dev/null -march=native 2>&1 | grep /cc1
exit
```

I had to disable AVX2, even my CPU does support it, using `-mno-avx2`.
