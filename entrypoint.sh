#!/bin/bash

if [ ! -z "${FORGEURL}" ] ; then
  echo "  url: ${FORGEURL}" >> config.yaml.bak
fi
if [ ! -z "${PROXYURL}" ] ; then
  echo "  proxy_url: ${PROXYURL}" >> config.yaml.bak
fi
if [ ! -z "${PROXYPORT}" ] ; then
  echo "  proxy_port: ${PROXYPORT}" >> config.yaml.bak
fi
if [ ! -z "${PROXYUSER}" ] ; then
  echo "  proxy_user: ${PROXYUSER}" >> config.yaml.bak
fi
if [ ! -z "${PORXYPASS}" ] ; then
  echo "  proxy_pass: ${PROXYPASS}" >> config.yaml.bak
fi
if [ -f config.yaml.bak ] ; then
  echo "---" > config.yaml
  echo "forge:" >> config.yaml
  cat config.yaml.bak >> config.yaml
  echo " " >> config.yaml
fi

/usr/local/bin/ruby puppetfile-version-checker.rb -p /puppetfile-in -r /report -u -o /puppetfile-out "$@"
