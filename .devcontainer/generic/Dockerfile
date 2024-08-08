# hadolint global ignore=DL4006,DL3008
FROM ubuntu:24.04

WORKDIR /home/monouser

# Install Node.js
RUN wget --progress=dot:giga -qO- https://deb.nodesource.com/setup_20.x | bash -

# Update and install specified versions of packages without recommending additional packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git=1:2.43.0-1ubuntu7.1 \
    wget=1.21.4-1ubuntu4.1 \
    sudo=1.9.15p5-3ubuntu5  \
    adduser=3.137ubuntu1 \
    zsh=5.9-6ubuntu2 \
    ca-certificates=20240203 \
    gnupg=2.4.4-2ubuntu17  \
    gh=2.45.0-1ubuntu0.1 \
    jq=1.7.1-3build1 \
    openssh-client=1:9.6p1-3ubuntu13.4 \
    nodejs npm && \
    rm -rf /var/lib/apt/lists/*

# Add new user and configure sudo
RUN useradd -m monouser && \
    echo "monouser:monouser" | chpasswd && \
    adduser monouser sudo && \
    echo "monouser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    chsh -s /usr/bin/zsh monouser

RUN chown -R monouser:monouser /home/monouser

RUN wget --progress=dot:giga -qO- https://get.docker.com/ | bash

USER monouser

# Install zsh-in-docker script
RUN wget --progress=dot:giga https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh