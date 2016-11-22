FROM bbvainnotech/k8s-nova-compute:latest
MAINTAINER BBVA Innovation <eurocloud-oneteam.group@bbva.com>


ENV OPENSTACK_VERSION=mitaka \
    neutronPBR=8.1.2

# Install requriments and the main packages
RUN     apt-get update && \
        apt-get install -y openvswitch-switch ipset && \
        rm -rf /var/lib/apt/lists/*

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
