FROM bbvainnotech/ubuntu-base-os:latest
MAINTAINER BBVA Innovation <eurocloud-oneteam.group@bbva.com>


ENV OPENSTACK_VERSION=mitaka \
    PBR=8.1.2 \
    CLIENT=1.22.0

RUN     apt-get update && \
        apt-get install -y openvswitch-switch iptables dnsmasq dnsmasq-utils arping && \
        rm -rf /var/lib/apt/lists/*

RUN    curl -fSL https://github.com/openstack/neutron/archive/${PBR}.zip -o neutron-${PBR}.zip \
    && unzip neutron-${PBR}.zip \
    && cd neutron-${PBR} \
    && pip install -r requirements.txt \
    && PBR_VERSION=${PBR}  pip install . \
    && PBR_VERSION=${PBR}  tox -egenconfig \
    && cp -r etc /etc/neutron \
    && mv /etc/neutron/neutron/* /etc/neutron/ \
    && mv /etc/neutron/neutron.conf.sample /etc/neutron/neutron.conf \
    && mv /etc/neutron/l3_agent.ini.sample /etc/neutron/l3_agent.ini \
    && mv /etc/neutron/dhcp_agent.ini.sample /etc/neutron/dhcp_agent.ini \
    && mv /etc/neutron/metadata_agent.ini.sample /etc/neutron/metadata_agent.ini \
    && mv /etc/neutron/plugins/ml2/ml2_conf.ini.sample /etc/neutron/plugins/ml2/ml2_conf.ini \
    && mv /etc/neutron/plugins/ml2/openvswitch_agent.ini.sample /etc/neutron/plugins/ml2/openvswitch_agent.ini \
    && pip install git+https://github.com/openstack/python-openstackclient.git@stable/${OPENSTACK_VERSION} \
    && pip install os-client-config==${CLIENT} \
    && cd - \
    && rm -rf neutron-${PBR}*

ADD     data /

RUN     chown root:root /bootstrap/*.sh && chmod a+x /bootstrap/*.sh

ENTRYPOINT  ["/bootstrap/bootstrap.sh"]
EXPOSE 9696

