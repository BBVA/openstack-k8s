FROM    ubuntu-base-os:v0.3
MAINTAINER BBVA Innovation <eurocloud-oneteam.group@bbva.com>


ENV OPENSTACK_VERSION=mitaka \
    novaPBR=13.1.0 \
    neutronPBR=8.1.2

# Install requriments and the main packages
RUN     apt-get update && \
        apt-get install -y qemu-kvm libvirt-bin dbus openvswitch-switch ipset python-libvirt && \
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
    && pip install python-openstackclient \
    && cd - \
    && rm -rf nova-${novaPBR}*

RUN    curl -fSL https://github.com/openstack/neutron/archive/${neutronPBR}.zip -o neutron-${neutronPBR}.zip \
    && unzip neutron-${neutronPBR}.zip \
    && cd neutron-${neutronPBR} \
    && pip install -r requirements.txt \
    && PBR_VERSION=${neutronPBR}  pip install . \
    && PBR_VERSION=${neutronPBR}  tox -egenconfig \
    && cp -r etc /etc/neutron \
    && mv /etc/neutron/neutron/* /etc/neutron/ \
    && mv /etc/neutron/neutron.conf.sample /etc/neutron/neutron.conf \
    && mv /etc/neutron/plugins/ml2/openvswitch_agent.ini.sample /etc/neutron/plugins/ml2/openvswitch_agent.ini \
    && cd - \
    && rm -rf neutron-${neutronPBR}*

ADD     data /

RUN     chown root:root /bootstrap/*.sh && chmod a+x /bootstrap/*.sh

ENTRYPOINT  ["/bootstrap/bootstrap.sh"]
