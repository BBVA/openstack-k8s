FROM    ubuntu-base-os:v0.2
MAINTAINER BBVA Innovation <eurocloud-oneteam.group@bbva.com>

ENV OPENSTACK_VERSION=mitaka \
    novaPBR=13.1.0 \
    neutronPBR=8.1.2

#### Install VRS
ADD     data /

# Install VRS
RUN apt-get -y update && \
    dpkg -i /Nuage-VSP/4.0R4/nuage-metadata-agent_4.0.4-49_all.deb  \
            /Nuage-VSP/4.0R4/nuage-openvswitch-common_4.0.4-49_all.deb  \
            /Nuage-VSP/4.0R4/nuage-openvswitch-switch_4.0.4-49_amd64.deb \
            /Nuage-VSP/4.0R4/nuage-python-openvswitch_4.0.4-49_all.deb ; exit 0

# Install requriments and the main packages
RUN     apt-get -fy install && \
	    apt-get -y install qemu-kvm libvirt-bin dbus bridge-utils iproute2 telnet ipset python-libvirt && \
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

RUN     chown root:root /bootstrap/*.sh && chmod a+x /bootstrap/*.sh

ENTRYPOINT  ["/bootstrap/bootstrap.sh"]
