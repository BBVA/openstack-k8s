FROM    nova-compute-base:v0.3
MAINTAINER BBVA Innovation <eurocloud-oneteam.group@bbva.com>

ADD     data /
# Install VRS
RUN    apt-get -y update \
    && dpkg -i /nuage-VSP/nuage-openvswitch-common_4.0.4-49_all.deb  \
            /nuage-VSP/nuage-openvswitch-switch_4.0.4-49_amd64.deb \
            /nuage-VSP/nuage-python-openvswitch_4.0.4-49_all.deb \
            /nuage-VSP/nuage-metadata-agent_4.0.4-49_all.deb ; exit 0 \
    && apt-get -fy install \
    && apt-get -y install libjson-perl python-twisted-core vlan

RUN   chown root:root /bootstrap/*.sh && chmod a+x /bootstrap/*.sh

ENTRYPOINT  ["/bootstrap/bootstrap.sh"]
