#!/bin/sh

if [ -n "${FORGEURL}" ] ; then
  echo "  url: ${FORGEURL}" >> config.yaml.forge
fi
if [ -n "${PROXYURL}" ] ; then
  echo "  proxy_url: ${PROXYURL}" >> config.yaml.forge
fi
if [ -n "${PROXYPORT}" ] ; then
  echo "  proxy_port: ${PROXYPORT}" >> config.yaml.forge
fi
if [ -n "${PROXYUSER}" ] ; then
  echo "  proxy_user: ${PROXYUSER}" >> config.yaml.forge
fi
if [ -n "${PORXYPASS}" ] ; then
  echo "  proxy_pass: ${PROXYPASS}" >> config.yaml.forge
fi

if [ -n "${APIVERSION}" ] ; then
  echo "  api_version: ${APIVERSION}" >> config.yaml.git
fi
if [ -n "${APIURL}" ] ; then
  echo "  api_url: ${APIURL}" >> config.yaml.git
fi
if [ -n "${TOKEN}" ] ; then
  echo "  token: ${TOKEN}" >> config.yaml.git
fi

echo "---" > config.yaml

if [ -f config.yaml.forge ] ; then
  echo "forge:" >> config.yaml
  cat config.yaml.forge >> config.yaml
fi

if [ -f config.yaml.git ] ; then
  echo "gitlab:" >> config.yaml
  cat config.yaml.git >> config.yaml
fi

echo " " >> config.yaml

if [ -x /usr/local/bin/ruby ] ; then
  RUBY="/usr/local/bin/ruby"
elif [ -x /usr/bin/ruby ] ; then
  RUBY="/usr/bin/ruby"
else
  RUBY="ruby"
fi

$RUBY puppetfile-version-checker.rb -p /puppetfile-in -r /report -u -o /puppetfile-out "$@"
