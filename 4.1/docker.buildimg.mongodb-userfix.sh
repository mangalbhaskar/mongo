#!/bin/bash

# Usage:
# source docker.buildimg.mongodb-userfix <docker-file-name> <docker-image-tag>

DOCKERFILE=$1
DOCKERTAG=$2

CONTEXT="$( cd "$( dirname "${BASH_SOURCE[0]}")" && pwd )"
# mkdir -p ${CONTEXT}

ARCH=$(uname -m)
TIME=$(date +%Y%m%d_%H%M)

# TAG="${DOCKERTAG}-${ARCH}-${TIME}"
# TAG="${DOCKERTAG}-${TIME}"
TAG="${DOCKERTAG}"
echo "Built new image ${TAG}"

## Fail on first error.
# set -e

MONGODB_USER=mongodb
MONGODB_GRP=mongodb

sudo userdel "$MONGODB_USER" && sudo groupdel "$MONGODB_GRP"
# add user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
sudo groupadd -r "$MONGODB_GRP" && sudo useradd -r -g "$MONGODB_USER" "$MONGODB_GRP"

echo "docker build --build-arg mongodb_user=$MONGODB_USER --build-arg mongodb_grp=$MONGODB_GRP --build-arg mongodb_user_id=$(id -u $MONGODB_USER) --build-arg mongodb_grp_id=$(id -g $MONGODB_USER) -t ${TAG} -f ${DOCKERFILE} ${CONTEXT}"
docker build --build-arg mongodb_user=$MONGODB_USER --build-arg mongodb_grp=$MONGODB_GRP --build-arg mongodb_user_id=$(id -u $MONGODB_USER) --build-arg mongodb_grp_id=$(id -g $MONGODB_USER) -t ${TAG} -f ${DOCKERFILE} ${CONTEXT}
