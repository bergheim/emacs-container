FROM alpine:3.22

RUN apk update && apk add --no-cache \
      emacs-x11 \
      zsh \
      dbus-x11 \
      fontconfig \
      ttf-dejavu \
      ripgrep \
      fd \
      font-jetbrains-mono \
      font-jetbrains-mono-nerd \
      font-noto-emoji \
      enchant2 \
      hunspell \
      hunspell-en \
      aspell \
      aspell-en \
      enchant2-dev \
      pkgconf \
      build-base \
      gnupg \
      pinentry \
      pinentry-tty

# Create user 'user' with Zsh shell
RUN adduser -D -h /home/tsb -s /bin/zsh tsb

USER tsb
ENV HOME /home/tsb
WORKDIR $HOME

# Create ~/.config/emacs (will be mounted) and ensure ~/.gnupg dir exists with perms
RUN mkdir -p $HOME/.config/emacs && \
    mkdir -p $HOME/.gnupg && \
    echo "allow-loopback-pinentry" > $HOME/.gnupg/gpg-agent.conf && \
    chmod 700 $HOME/.gnupg

# ENTRYPOINT script for GUI launch
COPY --chown=tsb:tsb entrypoint.sh $HOME/
RUN chmod +x $HOME/entrypoint.sh

ENTRYPOINT ["/home/tsb/entrypoint.sh"]
