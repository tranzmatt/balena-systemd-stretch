FROM balenalib/amd64-debian:stretch

ENV INITSYSTEM on

# Install Systemd
RUN apt-get update && apt-get install -y --no-install-recommends \
        systemd \
        systemd-sysv \
        redis-server \
    && rm -rf /var/lib/apt/lists/*

ENV container docker

# We never want these to run in a container
# Feel free to edit the list but this is the one we used
RUN systemctl mask \
    dev-hugepages.mount \
    sys-fs-fuse-connections.mount \
    sys-kernel-config.mount \
    display-manager.service \
    getty@.service \
    systemd-logind.service \
    systemd-remount-fs.service \
    getty.target \
    graphical.target \
    kmod-static-nodes.service

COPY entry.sh /usr/bin/entry.sh
COPY resin.service /etc/systemd/system/resin.service

RUN systemctl enable resin.service
RUN systemctl enable redis-server
#RUN service redis-server start
RUN systemctl enable redis-server

STOPSIGNAL 37
ENTRYPOINT ["/usr/bin/entry.sh"]


