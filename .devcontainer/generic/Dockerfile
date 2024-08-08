FROM ubuntu:24.04

# Set SHELL option for pipefail
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Update and install specified versions of packages without recommending additional packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git=2.4.6 \
    zsh=5.8 \
    wget=1.20.3 \
    sudo=1.8.31 && \
    rm -rf /var/lib/apt/lists/*

# Install zsh-in-docker script
RUN wget -qO- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.0/zsh-in-docker.sh | sh

# Install GitHub CLI
RUN mkdir -p /etc/apt/keyrings && \
    wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null && \
    chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && \
    apt-get install -y --no-install-recommends gh=2.54.0 && \
    rm -rf /var/lib/apt/lists/*

# Add new user and configure sudo
RUN useradd -m monouser && \
    echo "monouser:monouser" | chpasswd && \
    adduser monouser sudo && \
    echo "monouser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER monouser
WORKDIR /home/monouser
