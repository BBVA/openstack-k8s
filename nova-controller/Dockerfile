FROM bbvainnotech/ubuntu-base-os:latest
MAINTAINER BBVA Innovation <eurocloud-oneteam.group@bbva.com>


ENV OPENSTACK_VERSION=mitaka \
    PBR=13.1.0 \
    CLIENT=1.22.0

RUN     apt-get update && \
        apt-get install -qqy python-libvirt && \
        rm -rf /var/lib/apt/lists/*


RUN    curl -fSL https://github.com/openstack/nova/archive/${PBR}.zip -o nova-${PBR}.zip \
    && unzip nova-${PBR}.zip \
    && cd nova-${PBR} \
    && pip install -r requirements.txt \
    && PBR_VERSION=${PBR}  pip install . \
    && PBR_VERSION=${PBR}  tox -egenconfig \
    && cp -r nova/CA /usr/local/lib/python2.7/dist-packages/nova \
    && cp -r etc /etc/nova \
    && mv /etc/nova/nova/* /etc/nova/ \
    && mv /etc/nova/nova.conf.sample /etc/nova/nova.conf \
    && pip install git+https://github.com/openstack/python-openstackclient.git@stable/${OPENSTACK_VERSION} \
    && pip install os-client-config==${CLIENT} \
    && cd - \
    && rm -rf nova-${PBR}*

ADD     data /

RUN     chown root:root /bootstrap/*.sh && chmod a+x /bootstrap/*.sh

ENTRYPOINT  ["/bootstrap/bootstrap.sh"]
EXPOSE 8773 8774 8775 6080
