FROM bbvainnotech/kvm:latest
MAINTAINER BBVA Innovation <eurocloud-oneteam.group@bbva.com>
ENV container docker

ADD data /

RUN  echo "options kvm_intel ept=0" > /etc/modprobe.d/nuage_kvm_intel.conf \
     && chown root:root /bootstrap/*.sh \
     && chmod a+x /bootstrap/*.sh \
     && mv /bootstrap/jq-linux64 /usr/bin/jq \
     && chmod +x /usr/bin/jq

ENV AUTO_ATTACH='yes' \
    KVM_CPU_OPTS='-m 12288 -smp 4,sockets=4,cores=1,threads=1'

CMD [ "-device qxl-vga,id=video0,ram_size=67108864,vram_size=67108864,vgamem_mb=16,bus=pci.0,addr=0x3 -display none" ]

ENTRYPOINT ["/bootstrap/bootstrap.sh"]
