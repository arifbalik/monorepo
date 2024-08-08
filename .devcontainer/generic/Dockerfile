FROM ubuntu:latest

RUN apt-get update && apt-get install -y git zsh wget sudo
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.0/zsh-in-docker.sh)"

RUN mkdir -p -m 755 /etc/apt/keyrings \
    && wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install gh -y

# add new user monouser
RUN useradd -m monouser && echo "monouser:monouser" | chpasswd && adduser monouser sudo
RUN echo "monouser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
USER monouser
WORKDIR /home/monouser