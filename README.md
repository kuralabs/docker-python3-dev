About
=====

Python 3 ready container to build Python projects.

https://hub.docker.com/r/kuralabs/python3-dev/

Uses Ubuntu 17.04 as base and installs, among other things:

- python3.6
- python3.6-venv
- python3.6-pip
- python3.6-dev
- build-essential
- graphviz
- tox
- flake8
- git
- subversion

Also creates a python3 user that allows to test as a non-root user
(although it is a sudoer).

Usage
=====

    docker pull kuralabs/python3-dev:latest
    docker run -it kuralabs/python3-dev:latest bash
