#!/bin/bash

# Usage:
# source docker.buildimg.mongodb-userfix <docker-file-name> <docker-image-tag>

function build_mongodb_docker_img() {
	local MONGODB_VER=$1
	local DOCKERTAG=$2

	local LINUX_VERSION="$(lsb_release -sr)"
	local LINUX_CODE_NAME=$(lsb_release -sc)
	local LINUX_ID=$(lsb_release -si) ## Ubuntu, Kali

	local GPGCMD=gpg2
	local MONGODB_VER=4.1

	if [[ $LINUX_VERSION == "16.04" ]]; then
		## https://github.com/inversepath/usbarmory-debian-base_image/issues/9
		## Error fix: gpg: keyserver receive failed: Cannot assign requested address
	  GPGCMD=gpg
		MONGODB_VER=4.0
	fi

	if [ -z $MONGODB_VER ]; then		
		if [[ $LINUX_VERSION == "16.04" ]]; then
			## https://github.com/inversepath/usbarmory-debian-base_image/issues/9
			## Error fix: gpg: keyserver receive failed: Cannot assign requested address
		  GPGCMD=gpg
			MONGODB_VER=4.0
		fi
	fi

	local DOCKERFILE=$MONGODB_VER/Dockerfile.mongodb-userfix
	echo "DOCKERFILE: $DOCKERFILE"

	if [ -z $DOCKERTAG ]; then
		DOCKERTAG=mongouid
		echo "setting to default DOCKERTAG: $DOCKERTAG"
	fi

	local CONTEXT="$( cd "$( dirname "${BASH_SOURCE[0]}")" && pwd )/${MONGODB_VER}"
	echo "CONTEXT: $CONTEXT"

	# mkdir -p ${CONTEXT}

	local ARCH=$(uname -m)
	local TIME=$(date +%Y%m%d_%H%M)

	# local TAG="${DOCKERTAG}-${ARCH}-${TIME}"
	# local TAG="${DOCKERTAG}-${TIME}"
	local TAG="${DOCKERTAG}"
	echo "Built new image ${TAG}"

	## Fail on first error.
	# set -e

	local MONGODB_USER=mongodb
	local MONGODB_GRP=mongodb


	sudo userdel "$MONGODB_USER" && sudo groupdel "$MONGODB_GRP"
	# add user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
	sudo groupadd -r "$MONGODB_GRP" && sudo useradd -r -g "$MONGODB_USER" "$MONGODB_GRP"

	echo "docker build \
		--build-arg gpgcmd=$GPGCMD \
		--build-arg mongodb_user=$MONGODB_USER \
		--build-arg mongodb_grp=$MONGODB_GRP \
		--build-arg mongodb_user_id=$(id -u $MONGODB_USER) \
		--build-arg mongodb_grp_id=$(id -g $MONGODB_USER) \
		-t ${TAG} \
		-f ${DOCKERFILE} ${CONTEXT}"

	docker build \
		--build-arg gpgcmd=$GPGCMD \
		--build-arg mongodb_user=$MONGODB_USER \
		--build-arg mongodb_grp=$MONGODB_GRP \
		--build-arg mongodb_user_id=$(id -u $MONGODB_USER) \
		--build-arg mongodb_grp_id=$(id -g $MONGODB_USER) \
		-t ${TAG} \
		-f ${DOCKERFILE} ${CONTEXT}

}

build_mongodb_docker_img $1 $2
