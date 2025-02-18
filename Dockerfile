# vim: sw=4 et

FROM fedora:41

RUN set -ex \
    && dnf update --refresh --assumeyes

RUN set -ex \
    && dnf install --assumeyes \
        GeoIP-devel \
        autoconf \
        automake \
        binutils-gold \
        bzip2 \
        c-ares-devel \
        clang \
        cmake \
        curl \
        diffutils \
        gcc \
        gd \
        gd-devel \
        gettext-envsubst \
        git \
        glib2-devel \
        glibc-devel \
        glibc-headers-x86 \
        kernel-headers \
        libpng-devel \
        libtiff-devel \
        libtool \
        libxcrypt-devel \
        libxml2-devel \
        libxslt-devel \
        libzstd-devel \
        lld \
        make \
        openssl-devel \
        pax-utils \
        python3 \
        python3-pip \
        re2-devel \
        readline-devel \
        redhat-rpm-config \
        tzdata \
        wget \
        which \
        zlib-devel \
        zstd

RUN set -ex \
    && dnf install --assumeyes python3 python3-pip git curl wget zip vim autoconf213 nodejs which npm python3-devel redhat-rpm-config alsa-lib-devel dbus-glib-devel glibc-static gtk2-devel libstdc++-static libXt-devel nasm pulseaudio-libs-devel yasm gcc-c++ mercurial perl perl-FindBin perl-JSON-PP openssl-devel

RUN set -ex \
    && dnf install --assumeyes acl bind-utils coreutils curl findutils git htop iftop iotop iptables logrotate plocate ncdu neovim NetworkManager-tui python3 redhat-lsb-core rsync sudo sqlite tmux util-linux-user vim wget which zsh zsh-autosuggestions zsh-syntax-highlighting zstd python3-pyyaml python3-rich ripgrep langpacks-en

WORKDIR /src
RUN wget https://hg.mozilla.org/mozilla-central/raw-file/default/python/mozboot/bin/bootstrap.py -O /src/bootstrap.py

ENV SHELL=/usr/bin/zsh
ENV PATH="/root/bin:$PATH"
ENV MOZCONFIG="/src/mozconfig"
ENV LANGUAGE="en_US.UTF-8"
ENV LC_ALL="en_US.UTF-8"

# install CompileNix dotfiles
RUN set -ex \
    && mkdir -pv /root/.config/dotfiles/compilenix \
    && echo -e "enable_hush_login: true\nlink_desktop_software_configs: false\nlink_fonts: false" >/root/.config/dotfiles/compilenix/config.yml \
    && wget https://git.compilenix.org/CompileNix/dotfiles/-/raw/main/install.sh && chmod +x install.sh && ./install.sh && rm -f install.sh \
    && echo "SPACESHIP_BATTERY_SHOW=false" >>/root/.zshrc.env \
    && echo "SPACESHIP_GIT_SHOW=false" >>/root/.zshrc.env \
    && echo "SPACESHIP_GRADLE_SHOW=false" >>/root/.zshrc.env \
    && echo "ENABLE_ZSH_ASYNC_UPDATE_CHECK=false" >>/root/.zshrc.env \
    && echo "export PATH=\"/src/bin:$PATH\"" >>/root/.zshrc_include \
    && echo "export MOZCONFIG=/src/mozconfig" >>/root/.zshrc_include \
    && echo "export LANGUAGE=en_US.UTF-8" >>/root/.zshrc_include \
    && echo "export LC_ALL=en_US.UTF-8" >>/root/.zshrc_include

# install rust
RUN set -ex \
    && curl --proto '=https' --tlsv1.3 -sSf https://sh.rustup.rs >install-rust.sh \
    && sh install-rust.sh -y \
    && rm install-rust.sh

RUN set -ex \
    && export SCCACHE_VERSION="v0.8.2" \
    && wget --no-verbose "https://github.com/mozilla/sccache/releases/download/${SCCACHE_VERSION}/sccache-${SCCACHE_VERSION}-x86_64-unknown-linux-musl.tar.gz" -O "sccache-${SCCACHE_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
    && tar -xf "sccache-${SCCACHE_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
    && mkdir -pv "/root/.cargo/bin" \
    && cp -v "./sccache-${SCCACHE_VERSION}-x86_64-unknown-linux-musl/sccache" "/root/.cargo/bin/" \
    && rm -rv "./sccache-${SCCACHE_VERSION}-x86_64-unknown-linux-musl.tar.gz" "./sccache-${SCCACHE_VERSION}-x86_64-unknown-linux-musl" \
    && echo "export RUSTC_WRAPPER=\"/root/.cargo/bin/sccache\"" >>/root/.zshrc_include

COPY src/* bin/

CMD [ "/usr/bin/zsh" ]
