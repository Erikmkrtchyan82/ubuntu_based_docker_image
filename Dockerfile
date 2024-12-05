FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHON3_VERSION="3.11" \
    CLANG_VERSION="17" \
    CMAKE_VERSION="3.26.5"


# Install basic programs
RUN apt-get -q update -y && \
    apt-get -q install -y --no-install-recommends \
    software-properties-common apt-utils gpg-agent && \
    apt-get -q update -y && \
    add-apt-repository ppa:ubuntu-toolchain-r/test && \
    apt-get -q update -y && \
    apt-get -q install -y --no-install-recommends \
    jq \
    git \
    graphviz \
    wget \
    curl \
    jq \
    lcov \
    libstdc++6 \
    libstdc++-13-dev \
    zlib1g \
    g++-10 && \
    dpkg --configure -a && \
    rm -rf /var/lib/apt/lists/*

## Install Clang
RUN wget --show-progress --progress=dot:mega https://apt.llvm.org/llvm.sh && \
    chmod +x llvm.sh && \
    apt-get -q update -y && \
    ./llvm.sh ${CLANG_VERSION} all && \
    rm -f llvm.sh && \
    apt-get -q install -y --no-install-recommends iwyu && \
    mkdir -p /usr/lib/lib/python3.10/site-packages && \
    ln -sf /usr/lib/llvm-${CLANG_VERSION}/lib/python3.10/site-packages/lldb /usr/lib/lib/python3.10/site-packages/lldb && \
    ln -sf /usr/bin/lldb-${CLANG_VERSION} /usr/bin/lldb && \
    ln -sf /usr/bin/clang-${CLANG_VERSION} /usr/bin/clang && \
    ln -sf /usr/bin/clang++-${CLANG_VERSION} /usr/bin/clang++ && \
    ln -sf /usr/bin/clangd-${CLANG_VERSION} /usr/bin/clangd && \
    ln -sf /usr/bin/clang-format-${CLANG_VERSION} /usr/bin/clang-format && \
    rm -rf /var/lib/apt/lists/*

ENV CC=/usr/bin/clang-${CLANG_VERSION} \
    CXX=/usr/bin/clang++-${CLANG_VERSION} \
    LLVM_COV=llvm-cov-${CLANG_VERSION}

    ## Install Python3
RUN add-apt-repository -y ppa:deadsnakes/ppa && \
    apt-get -q install -y --no-install-recommends \
    python${PYTHON3_VERSION} \
    python${PYTHON3_VERSION}-venv \
    python${PYTHON3_VERSION}-distutils \
    python${PYTHON3_VERSION}-dev \
    libpcre2-8-0 \
    libmount-dev \
    xxd \
    pkg-config && \
    rm -rf /var/lib/apt/lists/*

RUN ln -sf /usr/bin/python${PYTHON3_VERSION} /usr/local/bin/python3 && \
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    /usr/local/bin/python3 get-pip.py && rm -f get-pip.py

# Set working directory
WORKDIR /app

# Set default command to run bash
CMD ["bash"]

