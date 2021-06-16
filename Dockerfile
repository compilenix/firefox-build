FROM fedora:34

RUN set -ex \
    && dnf update --refresh --assumeyes \
    && dnf install --assumeyes python2 python3 python3-pip git curl wget zip vim autoconf213 nodejs which npm python2-devel python3-devel redhat-rpm-config alsa-lib-devel dbus-glib-devel glibc-static gtk2-devel libstdc++-static libXt-devel nasm pulseaudio-libs-devel wireless-tools-devel yasm gcc-c++ mercurial \
    && dnf groupinstall --assumeyes "C Development Tools and Libraries" "GNOME Software Development" \
    && useradd -m --home-dir /src firefox \
    && echo "export PATH=\"/src/.mozbuild/git-cinnabar:$PATH\"" >>/src/.bashrc \
    && echo "export SHELL=/bin/bash" >>/src/.bashrc \
    && echo "export MOZCONFIG=/src/mozconfig" >>/src/.bashrc
COPY sudoers /etc/sudoers
USER firefox
WORKDIR /src
ENV SHELL=/bin/bash
ENV PATH="/src/.mozbuild/git-cinnabar:$PATH"
ENV MOZCONFIG="/src/mozconfig"
RUN wget https://hg.mozilla.org/mozilla-central/raw-file/default/python/mozboot/bin/bootstrap.py
