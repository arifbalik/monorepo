# hadolint global ignore=DL4006,DL3008
FROM ubuntu:24.04

# Update and install specified versions of packages without recommending additional packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git=1:2.43.0-1ubuntu7.1 \
    zsh=5.9-6ubuntu2 \
    wget=1.21.4-1ubuntu4.1 \
    sudo=1.9.15p5-3ubuntu5  \
    adduser=3.137ubuntu1 &&\
    rm -rf /var/lib/apt/lists/*

# Install zsh-in-docker script
RUN sh -c "$(wget --progress=dot:giga -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.0/zsh-in-docker.sh)"

# Install GitHub CLI
RUN mkdir -p /etc/apt/keyrings && \
    wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null && \
    chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && \
    apt-get install -y --no-install-recommends gh && \
    rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN wget --progress=dot:giga -qO- https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get update && apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

# Add new user and configure sudo
RUN useradd -m monouser && \
    echo "monouser:monouser" | chpasswd && \
    adduser monouser sudo && \
    echo "monouser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER monouser
WORKDIR /home/monouser
