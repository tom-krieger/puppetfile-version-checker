FROM ruby:2.7

MAINTAINER Thomas Krieger <tom@tom-krieger.de>
LABEL Description="Docker container for Puppetfile version checker" Version="0.1.0"

ENV FORGEURL=""
ENV PROXYURL=""
ENV PROXYPORT=""
ENV PROXYUSER=""
ENV PROXYPASS=""

RUN apt -y install unzip
RUN mkdir /opt/puppetfile-version-checker
ADD . /opt/puppetfile-version-checker/
RUN cd /opt/puppetfile-version-checker ; \
    bundler install
RUN chmod 755 /opt/puppetfile-version-checker/puppetfile-version-checker.rb \
              /opt/puppetfile-version-checker/entrypoint.sh

WORKDIR /opt/puppetfile-version-checker

ENTRYPOINT [ "/opt/puppetfile-version-checker/entrypoint.sh" ]
