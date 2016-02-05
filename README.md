[![Docker Repository on Quay.io](https://quay.io/repository/sameersbn/nginx/status "Docker Repository on Quay.io")](https://quay.io/repository/sameersbn/nginx)

# sameersbn/nginx:1.8.1

- [Introduction](#introduction)
  - [Contributing](#contributing)
  - [Issues](#issues)
- [Getting started](#getting-started)
  - [Installation](#installation)
  - [Quickstart](#quickstart)
  - [Command-line arguments](#command-line-arguments)
  - [Configuration](#configuration)
  - [Logs](#logs)
- [Maintenance](#maintenance)
  - [Upgrading](#upgrading)
  - [Shell Access](#shell-access)

# Introduction

`Dockerfile` to create a [Docker](https://www.docker.com/) container image for [NGINX](http://nginx.org/en/) with [ngx_pagespeed](https://github.com/pagespeed/ngx_pagespeed) and [nginx-rtmp-module](https://github.com/arut/nginx-rtmp-module) module support.

NGINX is a web server with a strong focus on high concurrency, performance and low memory usage. It can also act as a reverse proxy server for HTTP, HTTPS, SMTP, POP3, and IMAP protocols, as well as a load balancer and an HTTP cache.

## Contributing

If you find this image useful here's how you can help:

- Send a pull request with your awesome features and bug fixes
- Help users resolve their [issues](../../issues?q=is%3Aopen+is%3Aissue).
- Support the development of this image with a [donation](http://www.damagehead.com/donate/)

## Issues

If you are using SELinux, please check out [this policy](support/selinux)

Before reporting your issue please try updating Docker to the latest version and check if it resolves the issue. Refer to the Docker [installation guide](https://docs.docker.com/installation) for instructions.

SELinux users should try disabling SELinux using the command `setenforce 0` to see if it resolves the issue.

If the above recommendations do not help then [report your issue](../../issues/new) along with the following information:

- Output of the `docker version` and `docker info` commands
- The `docker run` command or `docker-compose.yml` used to start the image. Mask out the sensitive bits.
- Please state if you are using [Boot2Docker](http://www.boot2docker.io), [VirtualBox](https://www.virtualbox.org), etc.

# Getting started

## Installation

Automated builds of the image are available on [Dockerhub](https://hub.docker.com/r/sameersbn/nginx) and is the recommended method of installation.

> **Note**: Builds are also available on [Quay.io](https://quay.io/repository/sameersbn/nginx)

```bash
docker pull sameersbn/nginx:1.8.1
```

Alternatively you can build the image yourself.

```bash
docker build -t sameersbn/nginx github.com/sameersbn/docker-nginx
```

## Quickstart

Start NGINX using:

```bash
docker run --name nginx -d --restart=always \
  --publish 80:80 \
  sameersbn/nginx:1.8.1
```

*Alternatively, you can use the sample [docker-compose.yml](docker-compose.yml) file to start the container using [Docker Compose](https://docs.docker.com/compose/)*

## Command-line arguments

You can customize the launch command of NGINX server by specifying arguments to `nginx` on the `docker run` command. For example the following command prints the help menu of `nginx` command:

```bash
docker run --name nginx -it --rm \
  --publish 80:80 \
  sameersbn/nginx:1.8.1 -h
```

## Configuration

To configure NGINX as per your requirements edit the default [nginx.conf](nginx.conf) and mount it at `/etc/nginx/nginx.conf`.

```bash
docker run --name nginx -it --rm \
  --publish 80:80 \
  --volume /srv/docker/nginx/nginx.conf:/etc/nginx/nginx.conf \
  sameersbn/nginx:1.8.1
```

To configure virtual hosts, mount the directory containing the virtual host configurations at `/etc/nginx/sites-enabled/`.

```bash
docker run --name nginx -it --rm \
  --publish 80:80 \
  --volume /srv/docker/nginx/nginx.conf:/etc/nginx/nginx.conf \
  --volume /srv/docker/nginx/sites-enabled:/etc/nginx/sites-enabled \
  sameersbn/nginx:1.8.1
```

> **Note**: SELinux users should update the security context of the host mountpoints so that it plays nicely with Docker:
>
> ```bash
> mkdir -p /srv/docker/nginx
> chcon -Rt svirt_sandbox_file_t /srv/docker/nginx
> ```

To reload the NGINX configuration on a running instance you can send the `HUP` signal to the container.

```bash
docker kill -s HUP nginx
```

## Logs

To access the NGINX logs, located at `/var/log/nginx`, you can use `docker exec`. For example, if you want to tail the logs:

```bash
docker exec -it nginx tail -f /var/log/nginx/access.log
```

# Maintenance

## Upgrading

To upgrade to newer releases:

  1. Download the updated Docker image:

  ```bash
  docker pull sameersbn/nginx:1.8.1
  ```

  2. Stop the currently running image:

  ```bash
  docker stop nginx
  ```

  3. Remove the stopped container

  ```bash
  docker rm -v nginx
  ```

  4. Start the updated image

  ```bash
  docker run -name nginx -d \
    [OPTIONS] \
    sameersbn/nginx:1.8.1
  ```

## Shell Access

For debugging and maintenance purposes you may want access the containers shell. If you are using Docker version `1.3.0` or higher you can access a running containers shell by starting `bash` using `docker exec`:

```bash
docker exec -it nginx bash
```
