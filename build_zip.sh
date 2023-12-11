#!/bin/bash

if [ "$#" != "1" ]
then
  prog=`basename $0`
  echo "usage: $prog <x.y.z>"
  exit 2
fi

BUILDDIR=/tmp/puppetfile-checker-api
TARGET=/tmp/puppetfile-checker.tar.gz
CUR=$(pwd)
pwd
rm -rf ${BUILDDIR}
mkdir -p ${BUILDDIR}

cp -r api ${BUILDDIR}/
cp -r classes /${BUILDDIR}/classes
cp -r lib /${BUILDDIR}/lib
cp utilities.rb /${BUILDDIR}/utilities.rb
cp forge_client.rb /${BUILDDIR}/forge_client.rb
cp config.ru /${BUILDDIR}/config.ru
cp config.yaml.tpl /${BUILDDIR}/config.yaml
cp entrypoint-web.sh /${BUILDDIR}/entrypoint-web.sh
cp Gemfile /${BUILDDIR}/Gemfile
cp my_app.rb /${BUILDDIR}/my_app.rb

cd ${BUILDDIR}
pwd
tar cfz ${TARGET} .
mv -v ${TARGET} "${CUR}/puppetfile-checker-v${1}.tar.gz"
rm -rf ${BUILDDIR}

exit 0
