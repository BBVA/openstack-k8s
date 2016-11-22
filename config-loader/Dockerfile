FROM bbvainnotech/ubuntu-base:latest
MAINTAINER BBVA Innovation <eurocloud-oneteam.group@bbva.com>

ADD     data /

RUN     chown root:root /bootstrap/*.sh && chmod a+x /bootstrap/*.sh

ENTRYPOINT  ["/bootstrap/bootstrap.sh"]
