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


LINUX_VERSION="$(lsb_release -sr)"
LINUX_CODE_NAME=$(lsb_release -sc)
LINUX_ID=$(lsb_release -si) ## Ubuntu, Kali


# Ubuntu 18.04 LTS
if [[ $LINUX_ID == "Kali" ]]; then
  LINUX_VERSION=18.04
fi

echo $LINUX_VERSION


## https://github.com/inversepath/usbarmory-debian-base_image/issues/9
## Error fix: gpg: keyserver receive failed: Cannot assign requested address
if [[ $LINUX_VERSION == "16.04" ]]; then
  GPGCMD=gpg
fi

# Ubuntu 18.04 LTS
if [[ $LINUX_VERSION == "18.04" ]]; then
	GPGCMD=gpg2
fi

GPG_KEYS=E162F504A20CDF15827F718D4B7C549A058F8B6B

sudo userdel "$MONGODB_USER" && sudo groupdel "$MONGODB_GRP"
# add user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
sudo groupadd -r "$MONGODB_GRP" && sudo useradd -r -g "$MONGODB_USER" "$MONGODB_GRP"

echo "docker build \
	--build-arg gpgcmd=$GPGCMD \
	--build-arg linux_version=$LINUX_VERSION \
	--build-arg mongodb_user=$MONGODB_USER \
	--build-arg mongodb_grp=$MONGODB_GRP \
	--build-arg mongodb_user_id=$(id -u $MONGODB_USER) \
	--build-arg mongodb_grp_id=$(id -g $MONGODB_USER) \
	-t ${TAG} \
	-f ${DOCKERFILE} ${CONTEXT}"

docker build \
	--build-arg gpgcmd=$GPGCMD \
	--build-arg gpg_keys=$GPG_KEYS \
	--build-arg linux_version=$LINUX_VERSION \
	--build-arg mongodb_user=$MONGODB_USER \
	--build-arg mongodb_grp=$MONGODB_GRP \
	--build-arg mongodb_user_id=$(id -u $MONGODB_USER) \
	--build-arg mongodb_grp_id=$(id -g $MONGODB_USER) \
	-t ${TAG} \
	-f ${DOCKERFILE} ${CONTEXT}
