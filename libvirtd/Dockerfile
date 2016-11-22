FROM bbvainnotech/ubuntu-base-os:latest
MAINTAINER BBVA Innovation <eurocloud-oneteam.group@bbva.com>

# Install requriments and the main packages
RUN     apt-get update && \
        apt-get install -y qemu-kvm libvirt-bin dbus && \
        rm -rf /var/lib/apt/lists/*


ADD     data /

RUN     chown root:root /bootstrap/*.sh && chmod a+x /bootstrap/*.sh

ENTRYPOINT  ["/bootstrap/bootstrap.sh"]
