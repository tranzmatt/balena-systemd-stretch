FROM balenalib/ts4900-debian-python:3.6.6-stretch-run-20181207

ARG DISTRO=stretch
ARG BASE_ARCH=armv7l
ARG DEVICE_TYPE=gw

ENV DEBIAN_FRONTEND noninteractive 
ENV INITSYSTEM on
ENV container docker

RUN rm -rf /etc/apt/apt.conf.d/docker-gzip-indexes && \
    rm -rf /etc/apt/apt.conf.d/02_nocache_compress-indexes && \
    echo 'Dpkg::Use-Pty "0";' > /etc/apt/apt.conf.d/00usepty


# Install Systemd
RUN apt-get update && apt-get install -y --no-install-recommends \
        systemd \
        systemd-sysv \
        supervisor \
        redis-server \
        dropbear \
    && rm -rf /var/lib/apt/lists/*


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
COPY balena.service /etc/systemd/system/balena.service

RUN systemctl enable balena.service
RUN systemctl enable redis-server
RUN systemctl enable supervisor
#RUN systemctl enable serial-getty@ttymxc0.service 
RUN systemctl enable dropbear.service

STOPSIGNAL 37
#VOLUME ["/sys/fs/cgroup"]
ENTRYPOINT ["/usr/bin/entry.sh"]
CMD ["/bin/bash"]


