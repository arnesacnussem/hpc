FROM mcr.microsoft.com/vscode/devcontainers/base:0-focal

ENV LANG=en_US.UTF-8
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y \
    curl dumb-init zsh bash htop locales man nano git \
    ca-certificates apt-transport-https software-properties-common wget \
    procps openssh-client sudo vim.tiny lsb-release \
    rsync octave gtkwave build-essential dos2unix \
    octave-common octave-communications octave-communications-common

RUN wget -q https://xpra.org/gpg-2022.asc -O- | apt-key add - && \
    wget -q https://xpra.org/gpg-2018.asc -O- | apt-key add - && \
    add-apt-repository "deb https://xpra.org/ focal main" && \
    curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash - && \
    apt-get install -y nodejs xpra

RUN npm -g install yarn && yarn global add nodemon

ENV DISPLAY=:0
