FROM debian:bookworm-slim

RUN apt update && apt install -y curl && \
curl -O https://repo.percona.com/apt/percona-release_latest.generic_all.deb && \
apt install -y gnupg2 lsb-release gettext-base ./percona-release_latest.generic_all.deb && \
apt update && percona-release setup ppg15 && \
apt install -y percona-haproxy && \
mkdir -p /run/haproxy && \
chmod a+rw /run/haproxy && \
rm -f percona-release_latest.generic_all.deb && \
apt-get autoremove -y && apt-get clean && \
rm -rf /var/lib/apt/lists/* && \
rm -rf /tmp/* /var/tmp/*

COPY ./haproxy.cfg.template /etc/haproxy/haproxy.cfg.template
COPY ./start.sh /start.sh

CMD ["/start.sh"]