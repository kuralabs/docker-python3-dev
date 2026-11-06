FROM ghcr.io/astral-sh/uv:0.13.7 AS uv

FROM ubuntu:26.04
LABEL maintainer="info@kuralabs.io"
LABEL org.opencontainers.image.source="https://github.com/kuralabs/docker-python3-dev"
LABEL org.opencontainers.image.description="Python 3 development and CI container"
LABEL org.opencontainers.image.licenses="Apache-2.0"

# -----

USER root
ENV DEBIAN_FRONTEND=noninteractive
ENV USER_UID=1000
ENV USER_GID=1000
ENV DOCKER_GID=999


# Setup and install base system software
RUN echo "locales locales/locales_to_be_generated multiselect en_US.UTF-8 UTF-8" | debconf-set-selections \
    && echo "locales locales/default_environment_locale select en_US.UTF-8" | debconf-set-selections \
    && apt-get update \
    && apt-get --yes --no-install-recommends install \
        locales tzdata ca-certificates sudo \
        bash-completion iproute2 iputils-ping bind9-dnsutils \
        tar unzip curl rsync vim nano tree silversearcher-ag \
    && rm -rf /var/lib/apt/lists/*
ENV LANG=en_US.UTF-8


# Install Python stack
RUN apt-get update \
    && apt-get --yes --no-install-recommends install \
        python3 python3-dev \
        python3-pip python3-venv python3-setuptools \
        build-essential cmake \
        graphviz git openssh-client \
        libssl-dev libffi-dev \
    && rm -rf /var/lib/apt/lists/*


# Allow pip and uv to install into the system Python (PEP 668).
# This container is an ephemeral development environment, akin to a
# preloaded virtual environment. Config files are used so it also applies
# under sudo, which strips the environment variable.
COPY etc/pip.conf /etc/pip.conf
COPY etc/uv/uv.toml /etc/uv/uv.toml
ENV PIP_BREAK_SYSTEM_PACKAGES=1


# Install uv and Python tools, each isolated in its own environment
COPY --from=uv /uv /uvx /usr/local/bin/
RUN export UV_TOOL_DIR=/opt/uv-tools UV_TOOL_BIN_DIR=/usr/local/bin \
        UV_PYTHON=/usr/bin/python3 UV_PYTHON_DOWNLOADS=never UV_NO_CACHE=1 \
    && uv tool install tox --with tox-uv \
    && uv tool install flake8 --with pep8-naming \
    && uv tool install ruff \
    && uv tool install webdev


# Create development user
RUN echo "Removing default ubuntu user ..." \
    && userdel --remove ubuntu \
    && echo "Creating user and group ..." \
    && groupadd \
        --gid "${USER_GID}" \
        python3 \
    && groupadd \
        --gid "${DOCKER_GID}" \
        docker \
    && useradd \
        --create-home \
        --home-dir /home/python3 \
        --uid "${USER_UID}" \
        --gid python3 \
        --groups sudo,docker \
        --shell /bin/bash \
        --comment 'Python 3' \
        python3 \
    && echo "Allowing passwordless sudo to user ..." \
    && echo 'python3 ALL=NOPASSWD: ALL' > /etc/sudoers.d/python3


# Install entrypoint
COPY docker-entrypoint /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]


EXPOSE 8080/tcp
WORKDIR /home/python3
