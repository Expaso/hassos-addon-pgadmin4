# Local development

To build the lastest version using local docker, sswitch to the folder where the `dockerfile` resides, and run:

```
docker build --tag husselhans/hassos-addon-pgadmin4-aarch64:dev .
```
The dockerfile already contains the default build architecture and the default base image:

```
ARG BUILD_FROM=ghcr.io/hassio-addons/base/aarch64:9.2.0
ARG BUILD_ARCH=aarch64
```

Hereafter, you can push the image to dockerhub using cmd of docker desktop for testing purposes.


## Build using Home Asssitant Builder

To build the latest version using the HomeAssistant Addon Builder container, for `aarch64 architecture` for example, run:

```
docker run --rm --privileged -v ~/.docker:/root/.docker -v ~/hassos-addon-pgadmin4/pgadmin4:/data homeassistant/amd64-builder --target pgadmin4 --aarch64 -t /data
```

This will use the base images from the `build.json` file, and the architecture specified. Use `--all` instead of `--aarch64`  to build all architectures withih the `config.json`for example.

