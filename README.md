# OpenVoxProject OpenBolt Container

[![CI](https://github.com/openvoxproject/container-openbolt/actions/workflows/ci.yml/badge.svg)](https://github.com/openvoxproject/container-openbolt/actions/workflows/ci.yml)
[![License](https://img.shields.io/github/license/openvoxproject/container-openbolt.svg)](https://github.com/openvoxproject/container-openbolt/blob/main/LICENSE)
[![Sponsored by betadots GmbH](https://img.shields.io/badge/Sponsored%20by-betadots%20GmbH-blue.svg)](https://www.betadots.de)

## Introduction

This repository provides a container image for [OpenBolt](https://github.com/openvoxproject/openbolt).
OpenBolt is an orchestration tool for executing commands, scripts, tasks, and plans.

The image packages OpenBolt and its Ruby dependencies in an isolated bundle and runs OpenBolt as a non-root user.

## Container images

The image is published to the GitHub Container Registry and Docker Hub:

- `ghcr.io/openvoxproject/openbolt:latest` is the image published by the OpenVoxProject organization.
- `docker.io/voxpupuli/openbolt:latest` is the equivalent Docker Hub image.

Published images support the `linux/amd64` and `linux/arm64` platforms.

For reproducible environments, use a versioned image tag instead of `latest`.

## Usage

The container uses `bundle exec bolt` as its entry point.
Every argument after the image name is therefore passed directly to OpenBolt.

Display the OpenBolt help:

```shell
podman run --rm ghcr.io/openvoxproject/openbolt:latest --help
```

Display the installed OpenBolt version:

```shell
podman run --rm ghcr.io/openvoxproject/openbolt:latest --version
```

The default working directory is `/data`.
It is intended for an OpenBolt project and its inventory, modules, tasks, and plans.

Mount the current directory at `/data` to use it as the OpenBolt project directory:

```shell
podman run --interactive --tty --rm \
  --volume "$PWD:/data:Z" \
  ghcr.io/openvoxproject/openbolt:latest \
  plan show
```

The `:Z` suffix gives the container access to the bind mount on SELinux-enabled hosts.
It can be omitted where SELinux relabeling is not required.

The equivalent Docker command is:

```shell
docker run --interactive --tty --rm \
  --mount "type=bind,source=$PWD,target=/data" \
  ghcr.io/openvoxproject/openbolt:latest \
  plan show
```

OpenBolt configuration, inventory files, and credentials can be supplied through additional bind mounts.
Environment variables can also be used where supported by the project.

Mount sensitive files read-only whenever OpenBolt does not need to modify them.

Refer to the [OpenBolt documentation](https://github.com/openvoxproject/openbolt) for projects and inventory.
It also documents transports, tasks, plans, and command-line options.

## Runtime user and file permissions

The image runs as the unprivileged `openbolt` user with UID and GID `1001`.

Files mounted into `/data` must be readable by UID `1001`.
Directories must be writable by that UID if OpenBolt needs to create or change files.

Files created on a bind mount may therefore appear on the host as owned by UID `1001`.
The exact ownership depends on the container runtime and user-namespace configuration.

## Versions

The Ruby base image, Bundler version, and OpenBolt version are defined at the top of the [Containerfile](Containerfile).

They can be overridden for a local test build:

```shell
podman build \
  --build-arg BASE_IMAGE=docker.io/library/ruby:3.2-alpine \
  --build-arg RUBYGEM_BUNDLER=4.0.19 \
  --build-arg RUBYGEM_OPENBOLT=5.6.0 \
  --tag openbolt:test \
  --file Containerfile .
```

The OpenBolt gem version in the `Containerfile` is the authoritative version used for published image tags.

## Image design

The multi-stage build compiles the required gems in a builder stage.
It copies only the resulting OpenBolt bundle into the runtime stage.

The bundle is installed below `/opt/openbolt`.
It is kept separate from the Ruby installation provided by the base image.

The build also installs patched versions of selected default gems.
These versions provide security fixes newer than those included with the Ruby base image.

You can inspect the bundle state without invoking the OpenBolt entry point:

```shell
podman run --rm --entrypoint ash \
  ghcr.io/openvoxproject/openbolt:latest \
  -c "bundle check"
```

## How to release?

see [RELEASE.md](RELEASE.md)
