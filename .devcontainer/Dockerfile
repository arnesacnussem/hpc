# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.241.1/containers/ubuntu/.devcontainer/base.Dockerfile

# [Choice] Ubuntu version (use ubuntu-22.04 or ubuntu-18.04 on local arm64/Apple Silicon): ubuntu-22.04, ubuntu-20.04, ubuntu-18.04
ARG VARIANT="jammy"
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>


ENV LANG=en_US.UTF-8
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y \
    curl dumb-init zsh htop locales man nano git \
    ca-certificates apt-transport-https software-properties-common wget \
    git-lfs procps openssh-client sudo vim.tiny lsb-release bash \
    rsync octave ghdl libgl1-mesa-glx libegl1-mesa libxrandr2 libxrandr2 \
    libxss1 libxcursor1 libxcomposite1 libasound2 libxi6 libxtst6 curl build-essential \
    gtkwave psmisc octave-common octave-communications octave-communications-common \
    && git lfs install && \
    apt-get clean