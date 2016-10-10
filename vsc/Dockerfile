FROM bbvainnotech/kvm:latest
MAINTAINER BBVA Innovation <eurocloud-oneteam.group@bbva.com>
ENV container docker

RUN  echo "options kvm_intel ept=0" > /etc/modprobe.d/nuage_kvm_intel.conf \
     && yum install -y http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-8.noarch.rpm \
     && yum update -y \
     && yum install -y moreutils libguestfs-tools \
     && yum clean all

ADD data /

RUN  mv /bootstrap/jq-linux64 /usr/bin/jq \
     && chown root:root /bootstrap/*.sh

ENV AUTO_ATTACH='yes' \
    DISABLE_VGA='yes' \
    KVM_CPU_OPTS='-m 4051 -smp 4,sockets=4,cores=1,threads=1'

ENTRYPOINT ["/bootstrap/bootstrap.sh"]
