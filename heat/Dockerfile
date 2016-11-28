FROM bbvainnotech/ubuntu-base-os:latest
MAINTAINER BBVA Innovation <eurocloud-oneteam.group@bbva.com>


ENV OPENSTACK_VERSION=mitaka \
    PBR=6.0.0 \
    CLIENT=1.22.0

# Install requriments and the main packages

RUN    set -ex \
    && curl -fSL https://github.com/openstack/heat/archive/${PBR}.zip -o heat-${PBR}.zip \
    && unzip heat-${PBR}.zip \
    && cd heat-${PBR} \
    && pip install -r requirements.txt \
    && PBR_VERSION=${PBR}  pip install . \
    && PBR_VERSION=${PBR} tox -e genconfig \
    && cp -r etc/heat/ /etc/ \
    && mv /etc/heat/heat.conf.sample /etc/heat/heat.conf \
    && cp heat/cloudinit/config /usr/local/lib/python2.7/dist-packages/heat/cloudinit/ \
    && cp heat/cloudinit/boothook.sh /usr/local/lib/python2.7/dist-packages/heat/cloudinit/ \
    && chmod +x /usr/local/lib/python2.7/dist-packages/heat/cloudinit/boothook.sh \
    && pip install git+https://github.com/openstack/python-openstackclient.git@stable/${OPENSTACK_VERSION} \
    && pip install os-client-config==${CLIENT} \
    && cd - \
    && rm -rf heat-${PBR}*

ADD     data /

RUN     chown root:root /bootstrap/*.sh && chmod a+x /bootstrap/*.sh

ENTRYPOINT  ["/bootstrap/bootstrap.sh"]
EXPOSE 8000 8003 8004

