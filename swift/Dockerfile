FROM bbvainnotech/ubuntu-base-os:latest
MAINTAINER BBVA Innovation <eurocloud-oneteam.group@bbva.com>


ENV OPENSTACK_VERSION=mitaka \
    PBR=2.7.0 \
    CLIENT=1.22.0

# Install requriments and the main packages
RUN     apt-get update && \
        apt-get install -y  xfsprogs rsync && \
        rm -rf /var/lib/apt/lists/*

RUN    set -ex \
    && curl -L -O -sS http://launchpadlibrarian.net/227084865/liberasurecode1_1.1.0-2~ubuntu14.04.1_amd64.deb \
    && dpkg -i liberasurecode1_1.1.0-2~ubuntu14.04.1_amd64.deb \
    && curl -L -O -sS http://launchpadlibrarian.net/227084861/liberasurecode-dev_1.1.0-2~ubuntu14.04.1_amd64.deb \
    && dpkg -i liberasurecode-dev_1.1.0-2~ubuntu14.04.1_amd64.deb \
    && curl -fSL https://github.com/openstack/swift/archive/${PBR}.zip -o swift-${PBR}.zip \
    && unzip swift-${PBR}.zip \
    && cd swift-${PBR} \
    && useradd swift \
    && dd if=/dev/zero of=/srv/node bs=1024 count=102400 \
    && mkfs.ext3 -F /srv/node \
    && chown -R swift:swift /srv/node \
    && mkdir -p /var/cache/swift \
    && chown -R root:swift /var/cache/swift \
    && chmod -R 775 /var/cache/swift \
    && pip install keystonemiddleware \
    && pip install -r requirements.txt \
    && PBR_VERSION=${PBR}  pip install . \
    && cp -r etc/ /etc/swift/ \
    && mv /etc/swift/rsyncd.conf-sample /etc/rsyncd.conf \
    && mv /etc/swift/swift.conf-sample /etc/swift/swift.conf \
    && mv /etc/swift/proxy-server.conf-sample /etc/swift/proxy-server.conf \
    && mv /etc/swift/container-server.conf-sample /etc/swift/container-server.conf \
    && mv /etc/swift/object-server.conf-sample /etc/swift/object-server.conf \
    && mv /etc/swift/account-server.conf-sample /etc/swift/account-server.conf \
    && pip install git+https://github.com/openstack/python-openstackclient.git@stable/${OPENSTACK_VERSION} \
    && pip install os-client-config==${CLIENT} \
    && cd - \
    && rm -rf swift-${PBR}*

ADD     data /

RUN     chown root:root /bootstrap/*.sh && chmod a+x /bootstrap/*.sh

ENTRYPOINT  ["/bootstrap/bootstrap.sh"]
EXPOSE 8080 6000 6001 6002