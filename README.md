# OpenVoxProject OpenBolt Container

[![CI](https://github.com/openvoxproject/container-openbolt/actions/workflows/ci.yaml/badge.svg)](https://github.com/openvoxproject/container-openbolt/actions/workflows/ci.yaml)
[![License](https://img.shields.io/github/license/openvoxproject/container-openbolt.svg)](https://github.com/openvoxproject/container-openbolt/blob/main/LICENSE)
[![Sponsored by betadots GmbH](https://img.shields.io/badge/Sponsored%20by-betadots%20GmbH-blue.svg)](https://www.betadots.de)

## Introduction

This repository contains a containerized version of [OpenBolt](https://github.com/openvoxproject/openbolt) and plugins to facilitate orchestration with OpenBolt.

## Usage

You can run the container using a container runtime like Podman or Docker.
Here is an example command to run OpenBolt in an interactive terminal, mounting the current directory to `/data` inside the container:

```shell
podman run -it --rm -v $PWD:/data:Z ghcr.io/openvoxproject/openbolt:latest
```

For OpenBolt usage have a look at the upstream documentation <https://github.com/openvoxproject/openbolt>.

## Versions

To see which tool versions are included in the container see:

[build_versions.yaml](build_versions.yaml)

## How to release?

see [RELEASE.md](RELEASE.md)
