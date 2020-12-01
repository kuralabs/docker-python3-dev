About
=====

Python 3 ready container to build Python 3 projects, with support for
Continuous Integration.

https://hub.docker.com/r/kuralabs/python3-dev/

Uses Ubuntu 20.04 as base and installs a full Python 3.8 stack ready for
traditional or AsyncIO development. It install, among other things:

- python3
- python3-dev
- python3-pip
- python3-venv
- python3-wheel
- python3-setuptools
- openssh-client
- build-essential
- cmake
- graphviz
- flake8
- cryptography
- tox
- git
- rsync

Also creates a python3 user that allows to test as a non-root user
(although it is a sudoer).

Usage
=====

    docker pull kuralabs/python3-dev:latest
    docker run --interactive --tty --init kuralabs/python3-dev:latest bash

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
        kuralabs/python3-dev:latest bash

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


License
=======

    Copyright (C) 2017-2020 KuraLabs S.R.L

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
