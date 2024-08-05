# Base image and Zephyr SDK version
FROM ubuntu:noble

# Build arguments for SDK version and install directory
ARG ZEPHYR_SDK_VERSION=0.16.4
ARG ZEPHYR_SDK_INSTALL_DIR=/opt/zephyr-sdk-${ZEPHYR_SDK_VERSION}
ARG ZEPHYR_SDK_TOOLCHAINS="-t arm-zephyr-eabi -t xtensa-espressif_esp32s3_zephyr-elf"

# Environment setup for Python virtual environment
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Set the SHELL option -o pipefail before RUN with a pipe in it
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# Install core dependencies
RUN apt-get -y update && apt-get -y install --no-install-recommends \
    ca-certificates \
    cmake \
    device-tree-compiler \
    git \
    ninja-build \
    python3 \
    python3-pip \
    python3-venv \
    wget \
    xz-utils \
    sudo \
    gnupg \
    gdb-multiarch \
    openssh-client \
    clang-format-17

RUN ln -s /usr/bin/gdb-multiarch /usr/bin/arm-none-eabi-gdb

# Setup Python environment
RUN python3 -m venv $VIRTUAL_ENV

# Install Zephyr SDK
RUN export sdk_file_name="zephyr-sdk-${ZEPHYR_SDK_VERSION}_linux-$(uname -m)_minimal.tar.xz" && \
    wget -q "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${ZEPHYR_SDK_VERSION}/${sdk_file_name}" && \
    mkdir -p ${ZEPHYR_SDK_INSTALL_DIR} && \
    tar -xvf ${sdk_file_name} -C ${ZEPHYR_SDK_INSTALL_DIR} --strip-components=1 && \
    ${ZEPHYR_SDK_INSTALL_DIR}/setup.sh -c ${ZEPHYR_SDK_TOOLCHAINS} && \
    rm ${sdk_file_name}

# Install Python packages
RUN pip install --no-cache-dir wheel==0.43.0 west==1.2.0 pyelftools==0.31 puncover==0.4.1

# Add user for Zephyr development
RUN useradd -d /home/zephyr -ms /bin/bash -g root -G sudo zephyr && \
    echo "zephyr:root" | chpasswd && \
    mkdir /home/zephyr/workspace && \
    chown zephyr:root /home/zephyr/workspace

USER zephyr