FROM fedora:32

RUN dnf update --refresh --assumeyes
RUN dnf install --assumeyes python2 python3 python3-pip git curl wget zip
RUN dnf install --assumeyes autoconf213 nodejs which npm python2-devel redhat-rpm-config alsa-lib-devel dbus-glib-devel glibc-static gtk2-devel libstdc++-static libXt-devel nasm pulseaudio-libs-devel wireless-tools-devel yasm gcc-c++ mercurial
RUN dnf groupinstall --assumeyes "C Development Tools and Libraries" "GNOME Software Development"
COPY sudoers /etc/sudoers
RUN useradd -m --home-dir /src firefox
RUN echo "export PATH=\"/src/.mozbuild/git-cinnabar:$PATH\"" >>/src/.bashrc
RUN echo "export SHELL=/bin/bash" >>/src/.bashrc
USER firefox
WORKDIR /src
ENV SHELL=/bin/bash
ENV PATH="/src/.mozbuild/git-cinnabar:$PATH"
RUN wget https://hg.mozilla.org/mozilla-central/raw-file/default/python/mozboot/bin/bootstrap.py
RUN git clone https://github.com/glandium/git-cinnabar.git /src/.mozbuild/git-cinnabar
RUN git cinnabar download
COPY mozconfig .
