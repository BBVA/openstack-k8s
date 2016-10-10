FROM bbvainnotech/kvm:latest
MAINTAINER BBVA Innovation <eurocloud-oneteam.group@bbva.com>
ENV container docker

ADD data /

RUN  echo "options kvm_intel ept=0" > /etc/modprobe.d/nuage_kvm_intel.conf \
     && chown root:root /bootstrap/*.sh \
     && mv /bootstrap/jq-linux64 /usr/bin/jq

ENV AUTO_ATTACH='yes' \
    KVM_CPU_OPTS='-m 12288 -smp 4,sockets=4,cores=1,threads=1'

ENTRYPOINT ["/bootstrap/bootstrap.sh"]
