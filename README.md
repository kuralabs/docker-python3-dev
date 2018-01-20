About
=====

Python 3 ready container to build Python projects.

https://hub.docker.com/r/kuralabs/python3-dev/

Uses Ubuntu 17.10 as base and installs a full Python 3.6 stack ready for
traditional or AsyncIO development. It install, among other things:

- python3
- python3-dev
- python3-pip
- python3-venv
- python3-wheel
- python3-setuptools
- build-essential
- graphviz
- flake8
- tox
- git

Also creates a python3 user that allows to test as a non-root user
(although it is a sudoer).

Usage
=====

    docker pull kuralabs/python3-dev:latest
    docker run --interactive --tty --init kuralabs/python3-dev:latest bash
