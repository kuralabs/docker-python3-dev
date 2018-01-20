FROM ubuntu:17.10
LABEL mantainer="info@kuralabs.io"

# -----

USER root
ENV DEBIAN_FRONTEND noninteractive

# Setup and install base system software
RUN echo "locales locales/locales_to_be_generated multiselect en_US.UTF-8 UTF-8" | debconf-set-selections \
    && echo "locales locales/default_environment_locale select en_US.UTF-8" | debconf-set-selections \
    && apt-get update \
    && apt-get --yes --no-install-recommends install \
        locales tzdata ca-certificates sudo \
        bash-completion iproute2 curl nano tree \
    && rm -rf /var/lib/apt/lists/*
ENV LANG en_US.UTF-8


# Install Python stack
RUN apt-get update \
    && apt-get --yes --no-install-recommends install \
        python3 python3-dev \
        python3-pip python3-venv python3-wheel python3-setuptools \
        build-essential \
        graphviz git \
    && rm -rf /var/lib/apt/lists/*


# Install Python modules
ADD requirements.txt /tmp/requirements.txt
RUN pip3 install --no-cache-dir -r /tmp/requirements.txt \
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
EXPOSE 8080/TCP
WORKDIR /home/python3
