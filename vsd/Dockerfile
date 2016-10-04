FROM bbvainnotech/kvm:latest
MAINTAINER BBVA Innovation <eurocloud-oneteam.group@bbva.com>
ENV container docker

ADD data /

RUN  chown qemu:qemu /image/*.qcow2 \
     && echo "options kvm_intel ept=0" > /etc/modprobe.d/nuage_kvm_intel.conf \
     && yum update -y \
     && yum clean all

ENV AUTO_ATTACH='yes' \
    KVM_CPU_OPTS='-m 12288 -smp 4,sockets=4,cores=1,threads=1'
