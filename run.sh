#!/bin/sh

sudo podman run \
    -d \
    --name seadrive \
    --device /dev/fuse \
    --cap-add SYS_ADMIN \
    --security-opt apparmor:unconfined \
    -e SEAFILE_SERVER_URL="" \
    -e SEAFILE_USERNAME="" \
    -e SEAFILE_PASSWORD="" \
    seadrive