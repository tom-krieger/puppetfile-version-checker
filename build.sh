#!/bin/bash

REGISTRY="docker.home.tom-krieger.de"
NAME="puppetfile-version-checker"
VERSION="2.0.8"
DOCKERFILE=Dockerfile-alpine

if [ $# -ne 1 ] ; then
  prog=`basename $0`
  echo "usage: ${prog} <y/n>"
  exit 2
fi

if docker build -t ${NAME}:${VERSION} -f ${DOCKERFILE} . ; then
  if [ "${1}" = "y" ] ; then
    docker tag ${NAME}:${VERSION} "${REGISTRY}/${NAME}:${VERSION}"
    docker push "${REGISTRY}/${NAME}:${VERSION}"
  fi
fi

exit 0
