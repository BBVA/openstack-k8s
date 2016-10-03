FROM bbvainnotech/kvm:latest
MAINTAINER BBVA Innovation <eurocloud-oneteam.group@bbva.com>
ENV container docker

ADD data /
RUN  chown qemu:qemu /image/*.qcow2
RUN  echo "options kvm_intel ept=0" > /etc/modprobe.d/nuage_kvm_intel.conf \

ENV AUTO_ATTACH='yes' \
    KVM_CPU_OPTS='-m 4051 -smp 4,sockets=4,cores=1,threads=1'

RUN     chown root:root /bootstrap/*.sh && chmod a+x /bootstrap/*.sh
ENTRYPOINT ["/bootstrap/bootstrap.sh"]
