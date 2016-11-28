FROM bbvainnotech/ubuntu-base-os:latest
MAINTAINER BBVA Innovation <eurocloud-oneteam.group@bbva.com>


ENV OPENSTACK_VERSION=mitaka \
    novaPBR=13.1.0 \
    CLIENT=1.22.0

# Install requriments and the main packages
RUN     apt-get update && \
        apt-get install -y qemu-utils python-libvirt && \
        rm -rf /var/lib/apt/lists/*

RUN    curl -fSL https://github.com/openstack/nova/archive/${novaPBR}.zip -o nova-${novaPBR}.zip \
    && unzip nova-${novaPBR}.zip \
    && cd nova-${novaPBR} \
    && pip install -r requirements.txt \
    && PBR_VERSION=${novaPBR}  pip install . \
    && PBR_VERSION=${novaPBR}  tox -egenconfig \
    && cp -r etc /etc/nova \
    && mv /etc/nova/nova/* /etc/nova/ \
    && mv /etc/nova/nova.conf.sample /etc/nova/nova.conf \
    && pip install git+https://github.com/openstack/python-openstackclient.git@stable/${OPENSTACK_VERSION} \
    && pip install os-client-config==${CLIENT} \
    && cd - \
    && rm -rf nova-${novaPBR}*

ADD     data /

#RUN     chown root:root /bootstrap/*.sh && chmod a+x /bootstrap/*.sh

#ENTRYPOINT  ["/bootstrap/bootstrap-nova-compute-base.sh"]
