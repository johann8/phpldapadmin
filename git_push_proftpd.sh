#!/bin/bash
#set -x

# set variables
DOCKER_VERSION=1.1.0
MECHCENTRAL_VERSION=1.1.0
PATH_VERSION_TXT="/projects/meshcentral/version.txt"
PATH_DOCKER_FILE="/projects/meshcentral/Dockerfile"
PATH_BUILD_SCRIPT="/projects/meshcentral/build_image.sh"

# change MeshCentral Version
if  [ -f ${PATH_DOCKER_FILE} ]; then
   echo "MeshCentral version is changing..."
   sed -i -e "/# Update to Version/c\# Update to Version ${MECHCENTRAL_VERSION}" ${PATH_DOCKER_FILE}
   git add ${PATH_DOCKER_FILE} 
   git commit -m "install meshcentral version ${MECHCENTRAL_VERSION}"
   #git commit -m "install security fix for node.js"
   RES1=0
else
   echo "ERROR: File \"${PATH_DOCKER_FILE}\" not found."
   exit 0
fi

# Change Docker Container Version
if  [ -f ${PATH_VERSION_TXT} ]; then
   echo "Docker version is changing"
   sed -i -e "/v1.0/c\v${DOCKER_VERSION}" ${PATH_VERSION_TXT}
   git add ${PATH_VERSION_TXT}
   git commit -m "change docker version to ${DOCKER_VERSION}"
   RES2=0   
else
   echo "ERROR: File \"${PATH_VERSION_TXT}\" not found."
   exit 0
fi

# Change Version of build script
if  [ -f ${PATH_BUILD_SCRIPT} ]; then
   echo "Build script version is changing..."
   sed -i -e "/_VERSION=/c\_VERSION=${DOCKER_VERSION}" ${PATH_BUILD_SCRIPT}
   git add ${PATH_BUILD_SCRIPT}
   git commit -m "change build script version to ${DOCKER_VERSION}"
   RES3=0
else
   echo "Error: File \"${PATH_BUILD_SCRIPT}\" not found."
   exit 0
fi


if [ ${RES1} = 0 ] && [ ${RES2} = 0 ] && [ ${RES3} = 0 ]; then
   echo " Pushing changes to github..."
   git push -u origin master
else
   echo "Error: Pushing the changes to github"
   exit 0
fi

exit 0
