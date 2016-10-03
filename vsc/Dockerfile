FROM bbvainnotech/kvm:latest
MAINTAINER BBVA Innovation <eurocloud-oneteam.group@bbva.com>
ENV container docker

ADD data /

RUN  chown qemu:qemu /image/*.qcow2 \
     && echo "options kvm_intel ept=0" > /etc/modprobe.d/nuage_kvm_intel.conf \
     && yum install -y http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-8.noarch.rpm \
                        libguestfs-tools \
                        screen \
     && yum update -y \
     && yum install -y moreutils \
     && yum clean all \
     && mv /bootstrap/jq-linux64 /usr/bin/jq \
     && chmod +x /usr/bin/jq \
     && chown root:root /bootstrap/*.sh \
     && chmod a+x /bootstrap/*.sh

ENV AUTO_ATTACH='yes' \
    KVM_CPU_OPTS='-m 4051 -smp 4,sockets=4,cores=1,threads=1'

ENTRYPOINT ["/bootstrap/bootstrap.sh"]
