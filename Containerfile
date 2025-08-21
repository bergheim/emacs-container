FROM alpine:3.22.1

RUN apk update && apk add --no-cache \
    adwaita-fonts \
    adwaita-fonts-mono \
    adwaita-fonts-sans \
    adwaita-icon-theme \
    adwaita-icon-theme-dev \
    adwaita-xfce-icon-theme \
    aspell \
    aspell-en \
    breeze-cursors \
    build-base \
    coreutils \
    curl \
    dbus \
    emacs-pgtk-nativecomp \
    enchant2 \
    enchant2-dev \
    fd \
    fontconfig \
    font-jetbrains-mono-nerd \
    font-noto-emoji \
    git \
    gnupg \
    hunspell \
    hunspell-en \
    mesa-dri-gallium \
    pinentry \
    pinentry-tty \
    pkgconf \
    ripgrep \
    ttf-dejavu \
    wayland-libs-client \
    wayland-libs-cursor \
    wget \
    zsh

# Create user 'user' with Zsh shell
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN addgroup -g $GROUP_ID tsb && \
    adduser -D -h /home/tsb -s /bin/zsh -u $USER_ID -G tsb tsb

USER tsb
ENV HOME /home/tsb
WORKDIR $HOME

# Create ~/.config/emacs (will be mounted) and ensure ~/.gnupg dir exists with perms
RUN mkdir -p $HOME/.config/emacs && \
    mkdir -p $HOME/.gnupg && \
    echo "allow-loopback-pinentry" > $HOME/.gnupg/gpg-agent.conf && \
    chmod 700 $HOME/.gnupg

# don't load elfeed, org, etc
ENV EMACS_CONTAINER=1

# ENTRYPOINT script for GUI launch
COPY --chown=tsb:tsb entrypoint.sh $HOME/
RUN chmod +x $HOME/entrypoint.sh

ENTRYPOINT ["/home/tsb/entrypoint.sh"]
