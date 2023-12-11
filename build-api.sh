#!/bin/bash

REGISTRY="docker.tom-krieger.de"
NAME="puppetfile-version-checker-api"
VERSION="0.1.6"

if [ $# -ne 1 ] ; then
  prog=`basename $0`
  echo "usage: ${prog} <y/n>"
  exit 2
fi

docker build -t ${NAME}:${VERSION} -f Dockerfile-web .

if [ "${1}" = "y" ] ; then
  docker tag ${NAME}:${VERSION} "${REGISTRY}/${NAME}:${VERSION}"
  docker push "${REGISTRY}/${NAME}:${VERSION}"
fi

exit 0
