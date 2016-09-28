FROM ubuntu:14.04
MAINTAINER Eurocloud <eurocloud-oneteam.group@bbva.com>
# image base based on Ubuntu with the minimal packages to build on top of this new ones

RUN  apt-get update \
  && apt-get -y install curl openssl netcat jq tcpdump telnet\
  && rm -rf /var/lib/apt/lists/*
