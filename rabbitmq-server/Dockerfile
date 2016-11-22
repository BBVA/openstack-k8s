FROM bbvainnotech/ubuntu-base:latest
MAINTAINER BBVA Innovation <eurocloud-oneteam.group@bbva.com>

RUN     apt-get update \
 &&     apt-get install -y rabbitmq-server \
 &&     rm -rf /var/lib/apt/lists/*

ADD     data /
RUN     chown root:root /bootstrap/*.sh && chmod a+x /bootstrap/*.sh

ENTRYPOINT  ["/bootstrap/bootstrap.sh"]
EXPOSE  5672 15672 4369 25672
