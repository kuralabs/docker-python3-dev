FROM ubuntu:17.04
LABEL mantainer="info@kuralabs.io"

# Set the locale
RUN apt-get update \
    && apt-get --yes --no-install-recommends install \
        locales \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8


# Install base system software
RUN apt-get update \
    && apt-get --yes --no-install-recommends install \
        sudo ca-certificates \
        bash-completion iproute2 curl nano tree ack-grep unzip \
        subversion git \
    && rm -rf /var/lib/apt/lists/*


# Install Python stack
RUN apt-get update \
    && apt-get --yes --no-install-recommends install \
        python3.6 python3.6-venv python3.6-dev \
        build-essential \
        graphviz \
    && rm -rf /var/lib/apt/lists/* \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 100


# Install Python modules
ADD requirements.txt /tmp/requirements.txt
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py \
    && python3 get-pip.py \
    && rm get-pip.py \
    && pip3 install --no-cache-dir -r /tmp/requirements.txt \
    && rm -rf ~/.cache/pip


# Create development user
RUN addgroup \
        --quiet \
        --gid 1000 \
        python3 \
    && adduser \
        --quiet \
        --home /home/python3 \
        --uid 1000 \
        --ingroup python3 \
        --disabled-password \
        --shell /bin/bash \
        --gecos 'Python 3' \
        python3 \
    && usermod \
        --append \
        --groups sudo \
        python3 \
    && echo 'python3 ALL=NOPASSWD: ALL' > /etc/sudoers.d/python3


USER python3
WORKDIR /home/python3
