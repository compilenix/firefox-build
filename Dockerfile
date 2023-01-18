FROM fedora:37
# vim: sw=4 et

RUN set -ex \
    && dnf update --refresh --assumeyes \
    && dnf install --assumeyes python2 python3 python3-pip git curl wget zip vim autoconf213 nodejs which npm python2-devel python3-devel redhat-rpm-config alsa-lib-devel dbus-glib-devel glibc-static gtk2-devel libstdc++-static libXt-devel nasm pulseaudio-libs-devel yasm gcc-c++ mercurial perl-FindBin watchman \
    && dnf groupinstall --assumeyes "C Development Tools and Libraries" "GNOME Software Development" \
    && useradd -m --home-dir /src firefox \
COPY sudoers /etc/sudoers
USER firefox
WORKDIR /src
ENV SHELL=/usr/bin/zsh
ENV PATH="/src:$PATH"
ENV MOZCONFIG="/src/mozconfig"
ENV LANGUAGE="en_US.UTF-8"
ENV LC_ALL="en_US.UTF-8"
RUN wget https://hg.mozilla.org/mozilla-central/raw-file/default/python/mozboot/bin/bootstrap.py

# install CompileNix dotfiles
COPY ./dotfiles-config.yml /src/.config/dotfiles/compilenix/config.yml
RUN set -ex \
    && sudo dnf --assumeyes install acl bind-utils coreutils curl findutils git htop iftop iotop iptables logrotate mlocate ncdu neovim NetworkManager-tui python3 redhat-lsb-core rsync sudo sqlite tmux util-linux-user vim wget which zsh zsh-autosuggestions zsh-syntax-highlighting zstd python3-pyyaml python3-rich ripgrep langpacks-en \
    && sudo chown -R firefox:firefox /src/.config \
    && wget https://git.compilenix.org/CompileNix/dotfiles/-/raw/main/install.sh && chmod +x install.sh && ./install.sh && rm -f install.sh \
    && echo "SPACESHIP_BATTERY_SHOW=false" >>/src/.zshrc.env \
    && echo "SPACESHIP_GIT_SHOW=false" >>/src/.zshrc.env \
    && echo "SPACESHIP_GRADLE_SHOW=false" >>/src/.zshrc.env \
    && echo "ENABLE_ZSH_ASYNC_UPDATE_CHECK=false" >>/src/.zshrc.env \
    && echo "export PATH=\"/src:$PATH\"" >>/src/.zshrc_include \
    && echo "export MOZCONFIG=/src/mozconfig" >>/src/.zshrc_include \
    && echo "export LANGUAGE=en_US.UTF-8" >>/src/.zshrc_include \
    && echo "export LC_ALL=en_US.UTF-8" >>/src/.zshrc_include \
    && mv ~/.config/nvim ~/.config/nvimbackup \
    && git clone https://github.com/AstroNvim/AstroNvim ~/.config/nvim

# install rust
RUN curl --proto '=https' --tlsv1.3 -sSf https://sh.rustup.rs >install-rust.sh \
    && sh install-rust.sh -y \
    && rm install-rust.sh

COPY src/* bin/

CMD [ "/usr/bin/zsh" ]
