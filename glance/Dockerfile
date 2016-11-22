FROM bbvainnotech/ubuntu-base-os:latest
MAINTAINER BBVA Innovation <eurocloud-oneteam.group@bbva.com>


ENV OPENSTACK_VERSION=mitaka \
    PBR=12.0.0

# Install requriments and the main packages

RUN    set -ex \
    && curl -fSL https://github.com/openstack/glance/archive/${PBR}.zip -o glance-${PBR}.zip \
    && unzip glance-${PBR}.zip \
    && cd glance-${PBR} \
    && pip install -r requirements.txt \
    && PBR_VERSION=${PBR}  pip install . \
    && cp -r etc /etc/glance \
    && pip install python-openstackclient \
    && cd - \
    && rm -rf glance-${PBR}*

ADD     data /

RUN     chown root:root /bootstrap/*.sh && chmod a+x /bootstrap/*.sh

ENTRYPOINT  ["/bootstrap/bootstrap.sh"]
EXPOSE 9191 9292

