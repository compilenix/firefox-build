# Requirements
To build the docker image you need at least 2 GB disk space.

To run the container and building firefox you need at least additional 22 GB disk space.

- Open Container Runtime (i.e. containerd, mobby-engine)
- `bash`
- `envsubst` via gettext (Fedora)
- `desktop-file-install` via desktop-file-utils (Fedora)
- `tar` via tar (Fedora)


# Usage
## Prepare Build Enviroment
### Build Container Image
Clone and build docker image:

```sh
git clone https://git.compilenix.org/CompileNix/firefox-build.git
cd firefox-build
docker build -t firefox-build:fedora .
```


### Download Build Tools And Firefox Sources
Now you can prepare the build enviroment, by installing GIT cinnabar and downloading Firefox source using `bootstrap.py`.

When asked for `Destination directory for Git clone`, enter: `mozilla-unified`

```sh
mkdir -v dist mozilla-unified mozbuild; chmod -v 0777 dist mozilla-unified mozbuild
docker run -v $(pwd)/dist:/dist:z -v $(pwd)/mozbuild:/src/.mozbuild:z -v $(pwd)/mozilla-unified:/src/mozilla-unified:z -v $(pwd)/mozconfig:/src/mozconfig:z -v $(pwd)/patches:/src/patches:z -it --rm --name firefox-build firefox-build:fedora
git config --global fetch.prune true
git clone https://github.com/glandium/git-cinnabar.git /src/.mozbuild/git-cinnabar
git cinnabar download

python3 bootstrap.py --no-interactive --vcs=git --application-choice browser
```


## Build
Update your `mozconfig`, if you want. Then execute the snippet below. \
When asked for `Destination directory for Git clone`, enter nothing (hit enter).

```sh
docker build -t firefox-build:fedora .
docker run -v $(pwd)/dist:/dist:z -v $(pwd)/mozbuild:/src/.mozbuild:z -v $(pwd)/mozilla-unified:/src/mozilla-unified:z -v $(pwd)/mozconfig:/src/mozconfig:z -v $(pwd)/patches:/src/patches:z -it --rm --name firefox-build firefox-build:fedora
cd mozilla-unified
build-prepare.sh
apply-patches.py
build.sh
exit
./install.sh # you may run this with sudo if your current user is not permitted to write into the installation directory (default is ~/bin/)
```


# Patches
patches are located in the `patches` dir and are scanned & applied by runnning `apply-patches.py`. The configuration is saved at `patches/config.yml` as a simple `dict`.


# Building other branches / tags / bookmarks
After you've `git clone`'d or `git fetch`'ed and `cd`'ed into `mozilla-unified`, fetch the tags from origin with:

```sh
# this may take a while
git fetch --tags hg::tags: tag "*"
```

Now find the tag you want to checkout and build:

```sh
# get the 10 most recent firefox release tags
git tag | egrep 'FIREFOX(_[0-9]+)+_RELEASE' | sort --version-sort | tail -10

# get the 10 most recent firefox esr release tags
git tag | egrep 'FIREFOX(_[0-9]+)+_[0-9]esr_RELEASE' | sort --version-sort | tail -10
```

Take also a look into `src/build.sh` & `src/build-prepare.sh` and run the commands you need, manually.


# Troubleshooting
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
# continue #Build section with `build-prepare.sh`
```

