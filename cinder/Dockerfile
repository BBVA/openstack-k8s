FROM bbvainnotech/ubuntu-base-os:latest
MAINTAINER BBVA Innovation <eurocloud-oneteam.group@bbva.com>


ENV OPENSTACK_VERSION=mitaka \
    PBR=8.0.0 \
    CLIENT=1.22.0
    
RUN     apt-get update && \
        apt-get install -y nfs-common && \
        rm -rf /var/lib/apt/lists/*


RUN  set -ex; \
     curl -fSL https://github.com/openstack/cinder/archive/${PBR}.zip -o /opt/cinder-${PBR}.zip; \
     cd /opt; \
     unzip /opt/cinder-${PBR}.zip; \
     cd /opt/cinder-${PBR}; \
     pip install -r requirements.txt; \
     PBR_VERSION=${PBR}  pip install .; \
     sed -i 's/passenv.*/& PACKAGENAME/' tox.ini; \
     PBR_VERSION=${PBR} PACKAGENAME=cinder tox -e genconfig; \
     cp -r etc/cinder/ /etc/cinder/ ; \
     mv /etc/cinder/cinder.conf.sample /etc/cinder/cinder.conf; \
     mkdir -p /var/lib/cinder/nfs; \
     pip install git+https://github.com/openstack/python-openstackclient.git@stable/${OPENSTACK_VERSION}; \
     pip install os-client-config==${CLIENT}; \
     pip uninstall kombu -y; \
     pip install kombu==3.0.35

ADD     data /

RUN     chown root:root /bootstrap/*.sh && chmod a+x /bootstrap/*.sh

ENTRYPOINT  ["/bootstrap/bootstrap.sh"]
EXPOSE 8776
