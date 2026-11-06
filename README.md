About
=====

Python 3 ready container to build Python 3 projects, with support for
Continuous Integration.

Images are published for `linux/amd64` and `linux/arm64` to:

- GitHub Container Registry (recommended): `ghcr.io/kuralabs/python3-dev`
- Docker Hub (mirror): `kuralabs/python3-dev`
  https://hub.docker.com/r/kuralabs/python3-dev/

Uses Ubuntu 26.04 as base and installs a full Python 3.14 stack ready for
traditional or AsyncIO development. It installs, among other things:

- python3
- python3-dev
- python3-pip
- python3-venv
- python3-setuptools
- uv
- tox (with tox-uv)
- flake8 (with pep8-naming)
- ruff
- webdev
- openssh-client
- build-essential
- cmake
- libssl-dev
- libffi-dev
- graphviz
- git
- rsync
- ag (silversearcher-ag)
- ping (iputils-ping)
- dig (bind9-dnsutils)

Python tools (tox, flake8, ruff and webdev) are installed with `uv tool` in
isolated environments, so they don't interfere with the system Python.

Also creates a python3 user that allows to test as a non-root user
(although it is a sudoer).


Tags
====

- `latest`, `26.04`: Ubuntu 26.04 with Python 3.14. Rebuilt weekly.
- `20.04`: Ubuntu 20.04 with Python 3.8. Legacy, no longer updated.


Installing Python packages
==========================

This container is meant to be an ephemeral development environment, akin to a
preloaded virtual environment. Because of this, the
[PEP 668](https://peps.python.org/pep-0668/) "externally managed environment"
protection of the system Python is disabled for both `pip` and `uv` (see
`/etc/pip.conf` and `/etc/uv/uv.toml`), and `PIP_BREAK_SYSTEM_PACKAGES=1` is
set. Existing workflows keep working:

    pip3 install --user -r requirements.txt

Scripts installed with `--user` go to `~/.local/bin`, which is in the `PATH`.
Virtual environments are still available with `python3 -m venv` or `uv venv`.


Usage
=====

    docker pull ghcr.io/kuralabs/python3-dev:latest
    docker run --interactive --tty --init ghcr.io/kuralabs/python3-dev:latest bash

There is an entrypoint that can adjust container's user UID, user GID and the
Docker GID if required.

Adjusting the user UID and user GID allows the container user to match the
host's user and avoids permission issues in continuous integration systems that
runs the container. This is different to passing `--user` to the container,
as the files and HOME beloging to the container user will be changed too.

Adjusting the Docker GID allows the container user to access the `docker.sock`
to build containers inside the container if the socket was mounted.

To adjust user and groups identifiers run the container with the following
environment variables:

- `ADJUST_USER_UID`: Host's user UID to adjust container's user UID to.
- `ADJUST_USER_GID`: Host's user GID to adjust container's user GID to.
- `ADJUST_DOCKER_GID`: Host's Docker GID to adjust container's Docker GID to.

For example:

    ADJUST_USER_UID=$(id -u)
    ADJUST_USER_GID=$(id -g)
    ADJUST_DOCKER_GID=$(getent group docker | cut -d: -f3)

    docker run \
        --interactive --tty --init \
        --volume /var/run/docker.sock:/var/run/docker.sock \
        --env ADJUST_USER_UID=${ADJUST_USER_UID} \
        --env ADJUST_USER_GID=${ADJUST_USER_GID} \
        --env ADJUST_DOCKER_GID=${ADJUST_DOCKER_GID} \
        ghcr.io/kuralabs/python3-dev:latest bash

For the adjustment to work, the user starting the container must be root, which
is also the default. Make sure to pass `--user root:root` to the container if
unsure if the run environment sets another user. The container's entrypoint
will print a warning if the user running the container is not user 0.

Once the entrypoint ends its tasks, the user command is run as the
unpriviledged user `python3`

If you need to set the container to the same time zone as your host machine you
may use the following options:

    --env TZ=America/New_York \
    --volume /etc/timezone:/etc/timezone:ro \
    --volume /etc/localtime:/etc/localtime:ro \

There is also support for the execution of startup scripts by placing
executable scripts in the `/docker-entrypoint-init.d/` directory. To do so,
mount the startup scripts directory as follows:

    --volume /your/scripts/path:/docker-entrypoint-init.d/ \


Publishing
==========

Images are built, smoke tested (`test/smoke-test`) and published by GitHub
Actions (`.github/workflows/build.yml`) on every push to `main`, and weekly
to pick up security updates. Pull requests are built and tested but not
published. Publishing to Docker Hub requires the `DOCKERHUB_USERNAME` and
`DOCKERHUB_TOKEN` repository secrets.


License
=======

    Copyright (C) 2017-2026 KuraLabs S.R.L

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.
