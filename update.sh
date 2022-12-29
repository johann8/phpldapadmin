#!/bin/bash

# Abort on all errors, set -x
set -o errexit
#set -x

# Set Variables
IMAGE_NAME=phpldapadmin
DOCKER_DIR=/opt/${IMAGE_NAME}
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
esc=""
luef="${esc}[34m"; redf="${esc}[31m"; yellowf="${esc}[33m"; greenf="${esc}[32m"; cyanf="${esc}[36m"; pinkf="${esc}[35m"; xxxf="${esc}[1;32m"
boldon="${esc}[1m"; boldoff="${esc}[22m"
reset="${esc}[0m"


### ============= Start ============
#
echo ${greenf}=================================================================${reset}
echo "  Start updating Docker Image ${cyanf}\"${IMAGE_NAME}\"${reset} am ${TIMESTAMP}"
echo ${greenf}=================================================================${reset}
#
# Get container id
CONTAINER_ID="$(docker ps -a --format "{{.ID}}" --filter name=^/"${IMAGE_NAME}"$)"

# Get the image and hash of the running container
CONTAINER_IMAGE="$(docker inspect --format "{{.Config.Image}}" --type container ${CONTAINER_ID})"

RUNNING_IMAGE="$(docker inspect --format "{{.Image}}" --type container "${CONTAINER_ID}")"
echo " "
echo ${greenf}Running Image:${pinkf} ${RUNNING_IMAGE} ${reset}
echo " "

# Pull in latest version of the container and get the hash
docker pull "${CONTAINER_IMAGE}"
LATEST_IMAGE="$(docker inspect --format "{{.Id}}" --type image "${CONTAINER_IMAGE}")"
echo " "
echo ${greenf}Latest Image:${bluef} ${LATEST_IMAGE} ${reset}

# Update / Exit
if ! [ ${RUNNING_IMAGE} = ${LATEST_IMAGE} ]; then
  echo " "
  echo ${greenf}======================== ${cyanf}Message ${greenf}========================${reset}
  echo "Update von Docker Image ${cyanf}\"${IMAGE_NAME}\"${reset} wird gestartet..."
  echo " "
  cd ${DOCKER_DIR}
  #/usr/local/bin/docker-compose pull
  /usr/local/bin/docker-compose down && /usr/local/bin/docker-compose up -d
  docker rmi $(docker images -f "dangling=true" -q --no-trunc)
else
  echo " "
  echo ${greenf}======================== ${cyanf}Message ${greenf}========================${reset}
  echo "Es ist kein Update von Docker Image ${cyanf}\"${IMAGE_NAME}\"${reset} vorhanden."
  exit 0
fi

